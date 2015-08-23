require 'fileutils'

class LagottoZipUtility
  class Error < ::StandardError ; end
  class FileWriteLogNotFoundError < Error ; end
  class FileNotFoundError < Error ; end

  attr_reader :zip_filepath, :filemap

  def self.zip_filename_for(filename)
    filename.sub(/\.csv$/, ".zip")
  end

  def self.alm_combined_stats_zip_filename
    zip_filename_for(ReportWriter::ALM_COMBINED_STATS_FILENAME + "_#{Time.zone.now.to_date}.csv")
  end

  def self.zip_alm_combined_stats!
    report_filename = ReportWriter::ALM_COMBINED_STATS_FILENAME + "_#{Time.zone.now.to_date}.csv"
    alm_stats_write_log = FileWriteLog.most_recent_with_name(report_filename)

    if alm_stats_write_log.blank?
      raise FileWriteLogNotFoundError, "FileWriteLog record not found for #{report_filename} filename"
    end

    if !File.exists?(alm_stats_write_log.filepath)
      raise FileNotFoundError, "File not found at #{alm_stats_write_log.filepath} for #{alm_stats_write_log.inspect}"
    end

    zip_filepath = Pathname.new(ReportWriter.data_dir.join(alm_combined_stats_zip_filename))
    new(
      zip_filepath: zip_filepath,
      filemap: {
        # source path => zip file
        alm_stats_write_log.filepath => File.basename(alm_stats_write_log.filepath),
        Rails.root.join("docs/readmes/alm_combined_stats_report.md") => "README.md"
      }
    ).zip!
  end

  def self.zip_administrative_reports!
    most_recent_report_dir = ReportWriter.most_recent_report_dir || raise(FileNotFoundError, "No report_YYYY-MM-DD directory found!")

    filemap = Dir["#{most_recent_report_dir}/*"].reduce({}) do |hsh, path|
      hsh[path] = File.basename(path)
      hsh
    end

    zip_filepath = Pathname.new("#{most_recent_report_dir}.zip")
    new(
      zip_filepath: zip_filepath,
      filemap:filemap,
    ).zip!
  end

  def initialize(options={})
    @output = options[:output] || $stdout
    zip_filepath = options[:zip_filepath] || raise("Must supply :zip_filepath")
    @zip_filepath = Pathname.new(zip_filepath)
    @filemap = options[:filemap] || raise("Must supply a filemap, e.g. { source_file => filepath_in_zip }")
  end

  def zip!
    FileUtils.mkdir_p File.dirname(@zip_filepath)
    ZipUtility.zip!(zip_filepath) do |zip_utility|
      filemap.each_pair do |source_path, filepath_in_zip|
        zip_utility.add filepath_in_zip, source_path
      end
    end
    FileWriteLog.create!(filepath: zip_filepath, file_type: "ZipFile")
    @output.puts "#{zip_filepath.relative_path_from Rails.root} has been created!"
    zip_filepath
  end

end
