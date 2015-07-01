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
