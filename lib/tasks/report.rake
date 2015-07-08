require 'csv'
require 'date'

namespace :report do

  desc 'Generate CSV file with ALM stats for public sources'
  task :alm_stats => :environment do
    report = AlmStatsReport.new(Source.installed.without_private)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with ALM stats for private and public sources'
  task :alm_private_stats => :environment do
    report = AlmStatsReport.new(Source.installed)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_STATS_PRIVATE_CSV_FILENAME
  end

  desc 'Generate CSV file with Mendeley stats'
  task :mendeley_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "mendeley").first
    next if source.nil?

    report = MendeleyReport.new(source)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::MENDELEY_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC HTML usage stats over time'
  task :pmc_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_HTML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC PDF usage stats over time'
  task :pmc_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_PDF_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC combined usage stats over time'
  task :pmc_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_COMBINED_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC cumulative usage stats'
  task :pmc_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    report = PmcReport.new(source)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter HTML usage stats over time'
  task :counter_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_HTML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter PDF usage stats over time'
  task :counter_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_PDF_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter XML usage stats over time'
  task :counter_xml_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "xml"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_XML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter combined usage stats over time'
  task :counter_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_COMBINED_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with cumulative Counter usage stats'
  task :counter_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    report = CounterReport.new(source)
    date = Time.zone.now - 1.year
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with combined ALM stats'
  task :combined_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed.without_private),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_COMBINED_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with combined ALM private and public stats'
  task :combined_private_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_COMBINED_STATS_PRIVATE_CSV_FILENAME
  end

  desc 'Zip reports'
  task :zip => :environment do
    ReportZipper.zip_alm_combined_stats!
    ReportZipper.zip_administrative_reports!
  end

  desc 'Export ALM combined stats report to Zenodo'
  task :export_to_zenodo => :environment do
    if !ENV['ZENODO_KEY'] || !ENV['ZENODO_URL']
      raise <<-EOS.gsub(/^\s*/, '')
        Zenodo integration is not configured. To integrate with Zenodo
        please make sure you have set the ZENODO_KEY and ZENODO_URL
        environment variables.
      EOS
    end

    ENV['APPLICATION'] || raise("APPLICATION env variable must be set!")
    ENV['CREATOR'] || raise("CREATOR env variable must be set!")

    alm_combined_stats_zip_record = ReportWriteLog.most_recent_with_name(ReportZipper.alm_combined_stats_zip_filename)

    unless alm_combined_stats_zip_record
      puts  "No zip file (#{File.basename ReportZipper.alm_combined_stats_zip_filename}) found that needs to be exported!"
      next
    end

    publication_date = alm_combined_stats_zip_record.created_at.to_date

    data_export = ZenodoDataExport.create!(
      name: "alm_combined_stats_report",
      files: [alm_combined_stats_zip_record.filepath],
      publication_date: publication_date,
      title: "#{ENV['APPLICATION']} Summary Stats on #{publication_date}",
      description: "#{ENV['APPLICATION']} Summary Stats on #{publication_date}, generated by the Lagotto software.",
      creators: [ ENV['CREATOR'] ],
      keywords: ZENODO_KEYWORDS )

    DataExportJob.perform_later(id: data_export.id)
  end

  desc 'Generate all article stats reports'
  task :all_stats => [:environment, :alm_stats, :mendeley_stats, :pmc_html_stats, :pmc_pdf_stats, :pmc_combined_stats, :pmc_stats, :counter_html_stats, :counter_pdf_stats, :counter_xml_stats, :counter_combined_stats, :counter_stats, :combined_stats, :alm_private_stats, :combined_private_stats, :zip]
end
