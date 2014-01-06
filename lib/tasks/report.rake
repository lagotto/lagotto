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

require "csv"

namespace :report do

  task :all_stats, [:report_file] => :environment do |t, args|

    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    sql_stat = "select a.doi, a.published_on, a.title, rs.article_id"

    sources = Source.where(:private => false)
    sources.each do |source|
      sql_stat = sql_stat + ", group_concat(if(rs.source_id = #{source.id}, rs.event_count, NULL)) as '#{source.name}'"
    end

    sql_stat = sql_stat + " from retrieval_statuses rs, articles a where a.id = rs.article_id group by rs.article_id"

    db_config = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

    if db_config["host"].nil? || db_config["username"].nil? || db_config["password"].nil? || db_config["database"].nil?
      puts "Database configuration is missing.  Try again"
      exit
    end

    client = Mysql2::Client.new(:host => db_config["host"],
                                :username => db_config["username"],
                                :password => db_config["password"],
                                :database => db_config["database"])

    results = client.query(sql_stat)

    CSV.open(args.report_file, 'wb', :force_quotes => true) do |csv|
      csv << ["DOI", "Published", "Title"] + sources.map(&:display_name)
      results.each do |row|
        csv << [row["doi"], row["published_on"], row["title"]] + sources.map {|source| row[source.name]}
      end
    end
  end

  task :mendeley_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/mendeley"

    json = SourceHelper::get_json(service_url)

    results = json["rows"]
    mendeley_stats = Hash.new
    results.each { |result| mendeley_stats[result["key"]] = result["value"] }

    articles = Article.all
    CSV.open(args.report_file, 'wb', :force_quotes => true) do |csv|
      csv << ["DOI", "Mendeley Readers", "Mendeley Groups", "Mendeley Total"]
      articles.each do |article|
        mendeley_stat = mendeley_stats[article.doi]
        if !mendeley_stat.nil?
          csv << [article.doi, mendeley_stat["readers"], mendeley_stat["groups"], mendeley_stat["readers"] + mendeley_stat["groups"]]
        else
          csv << [article.doi, 0, 0, 0]
        end
      end
    end
  end

  task :counter_stats, [:report_url,:report_file] => :environment do |t, args|
    if args.report_url.nil? || args.report_file.nil?
      Rails.logger.error("report_url or report_file is missing")
      exit
    end

    start_year = 2003;
    start_month = 8;

    keys = []

    (start_month..12).each {|month| keys << "#{start_year}-#{month}"}

    (2004..Date.today.prev_year.year).each do | year |
      (1..12).each do | month |
        keys << "#{year}-#{month}"
      end
    end

    (1..Date.today.month).each {|month| keys << "#{Date.today.year}-#{month}"}

    json = SourceHelper::get_json(args.report_url)

    results = json["rows"]
    counter_html_stats = Hash.new
    results.each { |result| counter_html_stats[result["key"]] = result["value"] }

    articles = Article.where("doi like '10.1371/journal.p%'").order("doi")

    CSV.open(args.report_file, 'wb', :force_quotes => true) do |csv|

      csv << ["DOI"] + keys
      articles.each do |article|
        counter_html_stat = counter_html_stats[article.doi]
        if !counter_html_stat.nil?
          stat_row = Array.new
          keys.each do | key |
            stat = counter_html_stat[key]
            if !stat.nil?
              stat_row << stat
            else
              stat_row << 0
            end
          end
          csv << [article.doi] + stat_row
        else
          csv << [article.doi] + Array.new(keys.length, 0)
        end
      end
    end
  end

  task :counter_html_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/counter_html_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :counter_pdf_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/counter_pdf_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :counter_xml_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/counter_xml_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :counter_combined_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/counter_combined_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :pmc_html_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/pmc_html_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :pmc_pdf_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/pmc_pdf_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end

  task :pmc_combined_stats, [:report_file] => :environment do |t, args|
    if args.report_file.nil?
      Rails.logger.error("report_file is missing")
      exit
    end

    service_url = APP_CONFIG['couchdb_url']
    service_url = service_url + "_design/reports/_view/pmc_combined_views"

    Rake::Task["report:counter_stats"].invoke(service_url, args.report_file)
  end
end