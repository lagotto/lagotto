# encoding: UTF-8

require 'csv'
require 'zip'

class Report < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_and_belongs_to_many :users

  serialize :config, OpenStruct

  def self.available(role)
    if role == "user"
      where(:private => false)
    else
      all
    end
  end

  # Generate CSV with event counts for all works and installed sources
  def self.to_csv(options = {})
    sources = Source.installed
    sources = sources.where(:private => false) unless options[:include_private_sources]

    results = self.from_sql(sources: sources)

    CSV.generate do |csv|
      csv << ["pid_type", "pid", "publication_date", "title"] + sources.map(&:name)
      results.each { |row| csv << row.values }
    end
  end

  def self.from_sql(options = {})
    sql = "SELECT w.pid_type, w.pid, w.published_on, w.title"
    options[:sources].each do |source|
      sql += ", MAX(CASE WHEN rs.source_id = #{source.id} THEN rs.event_count END) AS #{source.name}"
    end
    sql += " FROM works w LEFT JOIN retrieval_statuses rs ON w.id = rs.work_id GROUP BY w.id"
    sanitized_sql = sanitize_sql_for_conditions(sql)
    results = ActiveRecord::Base.connection.exec_query(sanitized_sql)
  end

  # write report into folder with current date in name
  def self.write(filename, content, options = {})
    return nil unless filename && content

    date = options[:date] || Time.zone.now.to_date
    folderpath = "#{Rails.root}/data/report_#{date}"
    Dir.mkdir folderpath unless Dir.exist? folderpath
    filepath = "#{folderpath}/#{filename}"
    if IO.write(filepath, content)
      filepath
    else
      nil
    end
  end

  def self.read_stats(filename, options = {})
    return nil unless filename

    date = options[:date] || Time.zone.now.to_date
    filepath = "#{Rails.root}/data/report_#{date}/#{filename}.csv"
    if File.exist?(filepath)
      CSV.read(filepath, headers: true, encoding: "UTF-8" )
    else
      nil
    end
  end

  def self.merge_stats(options = {})
    filename = options[:include_private_sources] ? "alm_private_stats" : "alm_stats"
    alm_stats = read_stats(filename, options)
    return nil if alm_stats.blank?

    stats = [{ name: "mendeley_stats", headers: ["mendeley_readers", "mendeley_groups"] },
             { name: "pmc_stats", headers: ["pmc_html", "pmc_pdf"] },
             { name: "counter_stats", headers: ["counter_html", "counter_pdf"] }]
    stats.each do |stat|
      stat[:csv] = read_stats(stat[:name], options).to_a
    end

    # return alm_stats if no additional stats are found
    stats.reject! { |stat| stat[:csv].blank? }
    return alm_stats if stats.empty?

    generate_stats(alm_stats, stats)
  end

  def self.generate_stats(alm_stats, stats)
    CSV.generate do |csv|
      csv << alm_stats.headers + stats.reduce([]) { |sum, stat| sum + stat[:headers] }
      alm_stats.each do |row|
        stats.each do |stat|
          # find row based on pid, and discard the first two and last item (pid_type, pid and total).
          # otherwise pad with zeros
          # use rassoc as pid is second item
          match = stat[:csv].rassoc(row.field("pid"))
          match = match.present? ? match[2..3] : [0, 0]
          row.push(*match)
        end
        csv << row
      end
    end
  end

  def self.zip_file(options = {})
    date = options[:date] || Time.zone.now.to_date
    filename = "alm_report_#{date}.csv"
    filepath = "#{Rails.root}/data/report_#{date}/alm_report.csv"
    zip_filepath = "#{Rails.root}/public/files/alm_report.zip"
    return nil unless File.exist? filepath

    Zip::File.open(zip_filepath, Zip::File::CREATE) do |zipfile|
      zipfile.add(filename, filepath)
    end
    File.chmod(0755, zip_filepath)
    zip_filepath
  end

  def self.zip_folder(options = {})
    date = options[:date] || Time.zone.now.to_date
    folderpath = "#{Rails.root}/data/report_#{date}"
    zip_filepath = "#{Rails.root}/data/report_#{date}.zip"
    return nil unless File.exist? folderpath

    Zip::File.open(zip_filepath, Zip::File::CREATE) do |zipfile|
      Dir["#{folderpath}/*"].each do |filepath|
        zipfile.add(File.basename(filepath), filepath)
      end
    end
    FileUtils.rm_rf(folderpath)
    zip_filepath
  end

  def interval
    config.interval || 1.day
  end

  def interval=(value)
    config.interval = value.to_i
  end

  # Reports are sent via ActiveJob

  def send_error_report
    ReportMailer.send_error_report(self).deliver_later
  end

  def send_status_report
    ReportMailer.send_status_report(self).deliver_later
  end

  def send_work_statistics_report
    ReportMailer.send_work_statistics_report(self).deliver_later
  end

  def send_fatal_error_report(message)
    ReportMailer.send_fatal_error_report(self, message).deliver_later
  end

  def send_stale_source_report(source_ids)
    ReportMailer.send_stale_source_report(self, source_ids).deliver_later
  end

  def send_missing_workers_report
    ReportMailer.send_missing_workers_report(self).deliver_later
  end
end
