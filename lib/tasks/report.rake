#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'csv'
require 'date'

namespace :report do

  desc 'Generate CSV file with ALM stats for all sources'
  task :alm_stats => :environment do |t, args|
    filename = "alm_stats_#{Date.today.iso8601}.csv"
    filepath = "#{Rails.root}/data/#{filename}"

    csv = Report.to_csv(include_private_sources: ENV['PRIVATE'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif IO.write(filepath, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with Mendeley stats'
  task :mendeley_stats => :environment do |t, args|
    filename = "mendeley_#{Date.today.iso8601}.csv"
    filepath = "#{Rails.root}/data/#{filename}"

    csv = Mendeley.to_csv

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif IO.write(filepath, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate CSV file with PMC usage stats'
  task :pmc_stats => :environment do |t, args|
    if ENV['FORMAT']
      filename = "pmc_#{ENV['FORMAT']}_#{Date.today.iso8601}.csv"
    else
      filename = "pmc_#{Date.today.iso8601}.csv"
    end
    filepath = "#{Rails.root}/data/#{filename}"

    csv = Pmc.to_csv(format: ENV['FORMAT'], month: ENV['MONTH'], year: ENV['YEAR'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif IO.write(filepath, csv)
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
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with PMC PDF usage stats over time'
  task :pmc_pdf_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "pdf"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with PMC combined usage stats over time'
  task :pmc_combined_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "combined"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with Counter usage stats'
  task :counter_stats => :environment do |t, args|
    if ENV['FORMAT']
      filename = "counter_#{ENV['FORMAT']}_#{Date.today.iso8601}.csv"
    else
      filename = "counter_#{Date.today.iso8601}.csv"
    end
    filepath = "#{Rails.root}/data/#{filename}"

    csv = Pmc.to_csv(format: ENV['FORMAT'], month: ENV['MONTH'], year: ENV['YEAR'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif IO.write(filepath, csv)
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
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with Counter PDF usage stats over time'
  task :counter_pdf_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "pdf"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with Counter XML usage stats over time'
  task :counter_xml_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "xml"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with Counter combined usage stats over time'
  task :counter_combined_stats => :environment do |t, args|
    date = 1.year.ago.to_date
    ENV['FORMAT'] = "combined"
    ENV['MONTH'] = date.month.to_s
    ENV['YEAR'] = date.year.to_s
    Rake::Task["report:pmc_stats"].invoke
  end

  desc 'Generate CSV file with combined ALM stats'
  task :combined_stats => :environment do |t, args|
    filename = "alm_report_#{Date.today.iso8601}.csv"
    filepath = "#{Rails.root}/data/#{filename}"

    csv = Report.merge_stats(date: ENV['DATE'])

    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif IO.write(filepath, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end

  desc 'Generate all article stats reports'
  task :all_stats => [:environment, :alm_stats, :mendeley_stats, :pmc_stats, :pmc_html_stats, :pmc_pdf_stats, :pmc_combined_stats, :counter_stats, :counter_html_stats, :counter_pdf_stats, :counter_xml_stats, :counter_combined_stats, :combined_stats]
end