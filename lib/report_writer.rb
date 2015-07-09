require 'fileutils'

class ReportWriter
  # +data_dir+ determines where all of the reports are written to.
  class_attribute :data_dir

  self.data_dir = Rails.root.join("data")

  ALM_STATS_CSV_FILENAME = "alm_stats.csv"
  ALM_STATS_PRIVATE_CSV_FILENAME = "alm_private_stats.csv"

  MENDELEY_STATS_CSV_FILENAME = "mendeley_stats.csv"

  PMC_HTML_STATS_CSV_FILENAME = "pmc_html.csv"
  PMC_PDF_STATS_CSV_FILENAME = "pmc_pdf.csv"
  PMC_COMBINED_STATS_CSV_FILENAME = "pmc_combined.csv"
  PMC_STATS_CSV_FILENAME = "pmc_stats.csv"

  COUNTER_HTML_STATS_CSV_FILENAME = "counter_html.csv"
  COUNTER_PDF_STATS_CSV_FILENAME = "counter_pdf.csv"
  COUNTER_XML_STATS_CSV_FILENAME = "counter_xml.csv"
  COUNTER_COMBINED_STATS_CSV_FILENAME = "counter_combined.csv"
  COUNTER_STATS_CSV_FILENAME = "counter_stats.csv"

  ALM_COMBINED_STATS_CSV_FILENAME = "alm_report.csv"
  ALM_COMBINED_STATS_PRIVATE_CSV_FILENAME = "alm_private_report.csv"

  attr_reader :output_dir

  def self.write(*args)
    instance.write(*args)
  end

  def self.default_output_dir
    data_dir.join("report_#{Time.zone.now.to_date}")
  end

  def self.most_recent_report_dir
    Dir["#{data_dir}/report_*"].select do |f|
      File.directory?(f)
    end.sort.last
  end

  def self.instance
    @instance ||= ReportWriter.new output_dir: default_output_dir
  end

  def initialize(options={})
    @output_dir = options[:output_dir] || raise(ArgumentError, "Must supply :output_dir")
  end

  def write(report, options={})
    contents = options[:contents] || raise(ArgumentError, "Must supply :contents")
    filename = options[:filename] || raise(ArgumentError, "Must supply :filename")
    output = options[:output] || $stdout

    FileUtils.mkdir_p output_dir
    filepath = "#{output_dir}/#{filename}"

    if contents.nil?
      output.puts "No data for report \"#{filename}\"."
    elsif write_to_disk(report, contents: contents, filepath: filepath)
      output.puts "Report \"#{filename}\" has been written."
    else
      output.puts "Report \"#{filename}\" could not be written."
    end
  end

  private

  def write_to_disk(report, options={})
    contents = options[:contents] || raise(ArgumentError, "Must supply :contents")
    filepath = options[:filepath] || raise(ArgumentError, "Must supply :filepath")
    if contents.length > 0
      File.write(filepath, contents)
      ReportWriteLog.create!(filepath: filepath, report_type: report.class.name)
    end
  end

end
