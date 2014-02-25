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

    desc "Bulk-load articles from standard input"
    task :load => :environment do
      puts "Reading DOIs from standard input..."
      valid = []
      invalid = []
      duplicate = []
      created = []
      updated = []

      while (line = STDIN.gets)
        line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
        raw_doi, raw_published_on, raw_title = line.strip.split(" ", 3)

        doi = Article.from_uri(raw_doi.strip).values.first
        published_on = Date.parse(raw_published_on.strip) if raw_published_on
        title = raw_title.strip if raw_title
        if (doi =~ Article::FORMAT) and !published_on.nil? and !title.nil?
          valid << [doi, published_on, title]
        else
          puts "Ignoring DOI: #{raw_doi}, #{raw_published_on}, #{raw_title}"
          invalid << [raw_doi, raw_published_on, raw_title]
        end
      end

      puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"

      if valid.size > 0
        valid.each do |doi, published_on, title|
          existing = Article.find_by_doi(doi)
          unless existing
            article = Article.create(:doi => doi, :published_on => published_on,
                                     :title => title)
            created << doi
          else
            if existing.published_on != published_on or existing.title != title
              existing.published_on = published_on
              existing.title = title
              existing.save!
              updated << doi
            else
              duplicate << doi
            end
          end
        end
      end

      puts "Saved #{created.size} new articles, updated #{updated.size} articles, ignored #{duplicate.size} existing articles"
    end

    desc "Seed sample articles"
    task :seed => :environment do
      before = Article.count
      ENV['ARTICLES'] = "1"
      Rake::Task['db:seed'].invoke
      after = Article.count
      puts "Seeded #{after - before} articles"
    end

    desc "Delete articles with DOI from standard input"
    task :delete => :environment do
      puts "Reading DOIs from standard input..."
      valid = []
      invalid = []
      missing = []
      deleted = []

      while (line = STDIN.gets)
        line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
        raw_doi, raw_other = line.strip.split(" ", 2)

        doi = Article.from_uri(raw_doi.strip).values.first
        if (doi =~ Article::FORMAT)
          valid << [doi]
        else
          puts "Ignoring DOI: #{raw_doi}"
          invalid << [raw_doi]
        end
      end

      puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"

      if valid.size > 0
        valid.each do |doi|
          existing = Article.find_by_doi(doi)
          if existing
            existing.destroy
            deleted << doi
          else
            missing << doi
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
      Article.all.each do |article|
        article.update_date_parts
        article.save
      end
      puts "Date parts for #{Article.count} articles added"
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

    desc "Delete API requests, keeping last 1,000 requests"
    task :delete => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(1000).first
      unless request.nil?
        ApiRequest.where("created_at <= ?", request.created_at).delete_all
      end
      after = ApiRequest.count
      puts "Deleted #{before - after} API requests, #{after} API requests remaining"
    end
  end

  namespace :api_responses do

    desc "Delete all resolved API responses older than 24 hours"
    task :delete => :environment do
      before = ApiResponse.count
      ApiResponse.where(unresolved: false).where("created_at < ?", Time.zone.now - 1.day).destroy_all
      after = ApiResponse.count
      puts "Deleted #{before - after} resolved API responses, #{after} unresolved API responses remaining"
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
        if source.queueing?
          puts "Source #{source.display_name} has been activated and is now queueing."
        elsif source.idle?
          puts "Source #{source.display_name} has been activated and is now idle."
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
