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
    if options[:include_private_sources]
      sources = Source.installed
    else
      sources = Source.installed.where(:private => false)
    end

    sql = "SELECT w.pid_type, w.pid, w.published_on, w.title"
    sources.each do |source|
      sql += ", MAX(CASE WHEN rs.source_id = #{source.id} THEN rs.event_count END) AS #{source.name}"
    end
    sql += " FROM works w LEFT JOIN retrieval_statuses rs ON w.id = rs.work_id GROUP BY w.id"
    sanitized_sql = sanitize_sql_for_conditions(sql)
    results = ActiveRecord::Base.connection.exec_query(sanitized_sql)

    CSV.generate do |csv|
      csv << ["pid_type", "pid", "publication_date", "title"] + sources.map(&:name)
      results.each { |row| csv << row.values }
    end
  end

  # write report into folder with current date in name
  def self.write(filename, content, options = {})
    return nil unless filename && content

    date = options[:date] || Time.zone.now.to_date.to_s(:db)
    folderpath = "#{Rails.root}/data/report_#{date}"
    Dir.mkdir folderpath unless Dir.exist? folderpath
    filepath = "#{folderpath}/#{filename}"
    if IO.write(filepath, content)
      filepath
    else
      nil
    end
  end

  def self.read_stats(stat, options = {})
    date = options[:date] || Time.zone.now.to_date.to_s(:db)
    filename = "#{stat[:name]}.csv"
    filepath = "#{Rails.root}/data/report_#{date}/#{filename}"
    if File.exist?(filepath)
      CSV.read(filepath, headers: stat[:headers] ? stat[:headers] : :first_row, return_headers: true)
    else
      nil
    end
  end

  def self.merge_stats(options = {})
    if options[:include_private_sources]
      alm_stats = read_stats(name: "alm_private_stats")
    else
      alm_stats = read_stats(name: "alm_stats")
    end
    return nil if alm_stats.blank?

    stats = [{ name: "mendeley_stats", headers: ["pid_type", "pid", "mendeley_readers", "mendeley_groups", "mendeley"] },
             { name: "pmc_stats", headers: ["pid_type", "pid", "pmc_html", "pmc_pdf", "pmc"] },
             { name: "counter_stats", headers: ["pid_type", "pid", "counter_html", "counter_pdf", "counter"] }]
    stats.each do |stat|
      stat[:csv] = read_stats(stat, options).to_a
    end

    # return alm_stats if no additional stats are found
    stats.reject! { |stat| stat[:csv].blank? }
    return alm_stats if stats.empty?

    CSV.generate do |csv|
      alm_stats.each do |row|
        stats.each do |stat|
          # find row based on uid, and discard the first and last item (uid and total). Otherwise pad with zeros
          match = stat[:csv].assoc(row.field("pid"))
          match = match.present? ? match[1..-2] : [0, 0]
          row.push(*match)
        end
        csv << row
      end
    end
  end

  def self.zip_file(options = {})
    date = options[:date] || Time.zone.now.to_date.to_s(:db)
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
    date = options[:date] || Time.zone.now.to_date.to_s(:db)
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
    config.interval = value
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
