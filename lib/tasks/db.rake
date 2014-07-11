# encoding: UTF-8

# $HeadURL$
# $Id$
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

namespace :db do
  namespace :articles do
    desc "Bulk-load articles from Crossref API"
    task :import => :environment do |t, args|
      options = { from_update_date: ENV['FROM_UPDATE_DATE'],
                  until_update_date: ENV['UNTIL_UPDATE_DATE'],
                  from_pub_date: ENV['FROM_PUB_DATE'],
                  until_pub_date: ENV['UNTIL_PUB_DATE'],
                  type: ENV['TYPE'],
                  member: ENV['MEMBER'],
                  issn: ENV['ISSN'],
                  sample: ENV['SAMPLE'] }
      import = Import.new(options)
      number = ENV['SAMPLE'] || import.total_results
      import.queue_article_import
      puts "Started import of #{number} articles in the background..."
    end

    desc "Bulk-load articles from standard input"
    task :load => :environment do
      puts "Reading #{CONFIG[:uid]}s from standard input..."
      valid = []
      invalid = []
      duplicate = []
      created = []
      updated = []

      while (line = STDIN.gets)
        line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
        raw_uid, raw_published_on, raw_title = line.strip.split(" ", 3)

        uid = Article.from_uri(raw_uid.strip).values.first
        if raw_published_on
          date_parts = raw_published_on.split("-")
          year, month, day = date_parts[0], date_parts[1], date_parts[2]
        end
        title = raw_title.strip.chomp('.') if raw_title
        if Article.validate_format(uid) && year && title
          valid << [uid, year, month, day, title]
        else
          puts "Ignoring #{CONFIG[:uid]}: #{raw_uid}, #{raw_published_on}, #{raw_title}"
          invalid << [raw_uid, raw_published_on, raw_title]
        end
      end

      puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"

      if valid.size > 0
        valid.each do |uid, year, month, day, title|
          existing = Article.where(CONFIG[:uid].to_sym => uid).first
          unless existing
            article = Article.create(CONFIG[:uid].to_sym => uid,
                                     :year => year,
                                     :month => month,
                                     :day => day,
                                     :title => title)
            created << uid
          else
            if [existing.year, existing.month, existing.day].join("-") != [year, month, day].join("-") || existing.title != title
              existing.year = year
              existing.month = month
              existing.day = day
              existing.title = title
              existing.save!
              updated << uid
            else
              duplicate << uid
            end
          end
        end
      end

      puts "Saved #{created.size} new articles, updated #{updated.size} articles, ignored #{duplicate.size} existing articles"
    end

    desc "Seed sample articles"
    task :seed => :environment do
      before = Article.count
      ENV['ARTICLES'] = "true"
      Rake::Task['db:seed'].invoke
      after = Article.count
      puts "Seeded #{after - before} articles"
    end

    desc "Delete articles provided via standard input"
    task :delete => :environment do
      puts "Reading #{CONFIG[:uid]}s from standard input..."
      valid = []
      invalid = []
      missing = []
      deleted = []

      while (line = STDIN.gets)
        line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
        raw_uid, raw_other = line.strip.split(" ", 2)

        uid = Article.from_uri(raw_uid.strip).values.first
        if Article.validate_format(uid)
          valid << [uid]
        else
          puts "Ignoring #{CONFIG[:uid]}: #{raw_uid}"
          invalid << [raw_uid]
        end
      end

      puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"

      if valid.size > 0
        valid.each do |uid|
          existing = Article.where(CONFIG[:uid].to_sym => uid).first
          if existing
            existing.destroy
            deleted << uid
          else
            missing << uid
          end
        end
      end

      puts "Deleted #{deleted.size} articles, ignored #{missing.size} articles"
    end

    desc "Delete all articles"
    task :delete_all => :environment do
      before = Article.count
      Article.destroy_all unless Rails.env.production?
      after = Article.count
      puts "Deleted #{before - after} articles, #{after} articles remaining"
    end

    desc "Add missing sources"
    task :add_sources, [:date] => :environment do |t, args|
      if args.date.nil?
        puts "Date in format YYYY-MM-DD required"
        exit
      end

      articles = Article.where("published_on >= ?", args.date)

      if args.extras.empty?
        sources = Source.all
      else
        sources = Source.where("name in (?)", args.extras)
      end

      retrieval_statuses = []
      articles.each do |article|
        sources.each do |source|
          retrieval_status = RetrievalStatus.find_or_initialize_by_article_id_and_source_id(article.id, source.id, :scheduled_at => Time.zone.now)
          if retrieval_status.new_record?
            retrieval_status.save!
            retrieval_statuses << retrieval_status
          end
        end
      end

      puts "#{retrieval_statuses.count} retrieval status(es) added for #{sources.count} source(s) and #{articles.count} articles"
    end

    desc "Remove all HTML and XML tags from article titles"
    task :sanitize_title => :environment do
      Article.all.each { |article| article.save }
      puts "#{Article.count} article titles sanitized"
    end

    desc "Add publication year, month and day"
    task :date_parts => :environment do
      begin
        start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      rescue => e
        # raises error if invalid date supplied
        puts "Error: #{e.message}"
        exit
      end

      if start_date
        puts "Adding date parts for all articles published since #{start_date}."
        articles = Article.where("published_on >= ?", start_date)
      else
        articles = Article.all
      end

      articles.each do |article|
        article.update_date_parts
        article.save
      end
      puts "Date parts for #{articles.count} articles added"
    end
  end

  namespace :alerts do

    desc "Delete all resolved alerts"
    task :delete => :environment do
      Alert.unscoped {
        before = Alert.count
        Alert.destroy_all(:unresolved => false)
        after = Alert.count
        puts "Deleted #{before - after} resolved alerts, #{after} unresolved alerts remaining"
      }
    end
  end

  namespace :api_requests do

    desc "Delete API requests, keeping last 10,000 requests"
    task :delete => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(10000).first
      unless request.nil?
        ApiRequest.where("created_at <= ?", request.created_at).delete_all
      end
      after = ApiRequest.count
      puts "Deleted #{before - after} API requests, #{after} API requests remaining"
    end
  end

  namespace :api_responses do

    desc "Delete all API responses older than 24 hours"
    task :delete => :environment do
      before = ApiResponse.count
      ApiResponse.where("created_at < ?", Time.zone.now - 1.day).delete_all
      after = ApiResponse.count
      puts "Deleted #{before - after} API responses, #{after} API responses remaining"
    end
  end

  namespace :sources do

    desc "Activate sources"
    task :activate => :environment do |t, args|
      if args.extras.empty?
        sources = Source.inactive
      else
        sources = Source.inactive.where("name in (?)", args.extras)
      end

      if sources.empty?
        puts "No inactive source found."
        exit
      end

      sources.each do |source|
        source.activate
        if source.waiting?
          puts "Source #{source.display_name} has been activated and is now waiting."
        else
          puts "Source #{source.display_name} could not be activated."
        end
      end
    end

    desc "Inactivate sources"
    task :inactivate => :environment do |t, args|
      if args.extras.empty?
        sources = Source.active
      else
        sources = Source.active.where("name in (?)", args.extras)
      end

      if sources.empty?
        puts "No active source found."
        exit
      end

      sources.each do |source|
        source.inactivate
        if source.inactive?
          puts "Source #{source.display_name} has been inactivated."
        else
          puts "Source #{source.display_name} could not be inactivated."
        end
      end
    end

    desc "Install sources"
    task :install => :environment do |t, args|
      if args.extras.empty?
        sources = Source.available
      else
        sources = Source.available.where("name in (?)", args.extras)
      end

      if sources.empty?
        puts "No available source found."
        exit
      end

      sources.each do |source|
        source.install
        unless source.available?
          puts "Source #{source.display_name} has been installed."
        else
          puts "Source #{source.display_name} could not be installed."
        end
      end
    end

    desc "Uninstall sources"
    task :uninstall => :environment do |t, args|
      if args.extras.empty?
        puts "No source name provided."
        exit
      else
        sources = Source.installed.where("name in (?)", args.extras)
      end

      if sources.empty?
        puts "No installed source found."
        exit
      end

      sources.each do |source|
        source.uninstall
        if source.available?
          puts "Source #{source.display_name} has been uninstalled."
        elsif source.retired?
          puts "Source #{source.display_name} has been retired."
        else
          puts "Source #{source.display_name} could not be uninstalled."
        end
      end
    end
  end
end
