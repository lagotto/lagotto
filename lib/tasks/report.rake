require 'csv'
require 'date'

namespace :report do

  desc 'Generate CSV file with ALM stats for public sources'
  task :alm_stats => :environment do |t, args|
    filename = "alm_stats.csv"

    csv = Report.to_csv

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with ALM stats for private and public sources'
  task :alm_private_stats => :environment do |t, args|
    filename = "alm_private_stats.csv"

    csv = Report.to_csv(include_private_sources: true)

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with Mendeley stats'
  task :mendeley_stats => :environment do |t, args|
    filename = "mendeley_stats.csv"

    # check that source is installed
    source = Source.visible.where(name: "mendeley").first
    next if source.nil?

    csv = source.to_csv

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with PMC usage stats'
  task :pmc => :environment do |t, args|
    if ENV['FORMAT']
      filename = "pmc_#{ENV['FORMAT']}.csv"
    else
      filename = "pmc_stats.csv"
    end

    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    csv = source.to_csv(format: ENV['FORMAT'], month: ENV['MONTH'], year: ENV['YEAR'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with PMC HTML usage stats over time'
  task :pmc_html_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "html"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc"].invoke
    Rake::Task["report:pmc"].reenable
  end

  desc 'Generate CSV file with PMC PDF usage stats over time'
  task :pmc_pdf_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "pdf"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc"].invoke
    Rake::Task["report:pmc"].reenable
  end

  desc 'Generate CSV file with PMC combined usage stats over time'
  task :pmc_combined_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "combined"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc"].invoke
    Rake::Task["report:pmc"].reenable
  end

  desc 'Generate CSV file with PMC cumulative usage stats'
  task :pmc_stats => :environment do |t, args|
    ENV['FORMAT'] = nil
    ENV['MONTH'] = nil
    ENV['YEAR'] = nil
    Rake::Task["report:pmc"].invoke
    Rake::Task["report:pmc"].reenable
  end

  desc 'Generate CSV file with Counter usage stats'
  task :counter => :environment do |t, args|
    if ENV['FORMAT']
      filename = "counter_#{ENV['FORMAT']}.csv"
    else
      filename = "counter_stats.csv"
    end

    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    csv = source.to_csv(format: ENV['FORMAT'], month: ENV['MONTH'], year: ENV['YEAR'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with Counter HTML usage stats over time'
  task :counter_html_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "html"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:counter"].invoke
    Rake::Task["report:counter"].reenable
  end

  desc 'Generate CSV file with Counter PDF usage stats over time'
  task :counter_pdf_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "pdf"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:counter"].invoke
    Rake::Task["report:counter"].reenable
  end

  desc 'Generate CSV file with Counter XML usage stats over time'
  task :counter_xml_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "xml"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:counter"].invoke
    Rake::Task["report:counter"].reenable
  end

  desc 'Generate CSV file with Counter combined usage stats over time'
  task :counter_combined_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "combined"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:counter"].invoke
    Rake::Task["report:counter"].reenable
  end

  desc 'Generate CSV file with cumulative Counter usage stats'
  task :counter_stats => :environment do |t, args|
    ENV['FORMAT'] = nil
    ENV['MONTH'] = nil
    ENV['YEAR'] = nil
    Rake::Task["report:counter"].invoke
    Rake::Task["report:counter"].reenable
  end

  desc 'Generate CSV file with combined ALM stats'
  task :combined_stats => :environment do |t, args|
    filename = "alm_report.csv"

    csv = Report.merge_stats(date: ENV['DATE'])
    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with combined ALM private and public stats'
  task :combined_private_stats => :environment do |t, args|
    filename = "alm_private_report.csv"

    csv = Report.merge_stats(include_private_sources: true, date: ENV['DATE'])
    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Zip reports'
  task :zip => :environment do |t, args|

    folderpath = "#{Rails.root}/data/report_#{Date.today.iso8601}"
    if not Dir.exist? folderpath
      puts "No reports to compress."
    elsif Report.zip_file && Report.zip_folder
       puts "Reports have been compressed."
    else
      puts "Reports could not be compressed."
    end
  end

  desc 'Generate all article stats reports'
  task :all_stats => [:environment, :alm_stats, :mendeley_stats, :pmc_html_stats, :pmc_pdf_stats, :pmc_combined_stats, :pmc_stats, :counter_html_stats, :counter_pdf_stats, :counter_xml_stats, :counter_combined_stats, :counter_stats, :combined_stats, :alm_private_stats, :combined_private_stats, :zip]
end
