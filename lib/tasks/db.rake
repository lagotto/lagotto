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

      puts "Saved #{created.size} new articles, updated #{updated.size} articles, ignored #{duplicate.size} other existing articles"
    end

    desc "Seed sample articles"
    task :seed => :environment do
      before = Article.count
      ENV['ARTICLES'] = "1"
      Rake::Task['db:seed'].invoke
      after = Article.count
      puts "Seeded #{after - before} articles"
    end

    desc "Delete all articles"
    task :delete => :environment do
      before = Article.count
      Article.destroy_all unless Rails.env.production?
      after = Article.count
      puts "Deleted #{before - after} articles, #{after} articles remaining"
    end

  end

  namespace :error_messages do

    desc "Delete messages for all resolved errors"
    task :delete => :environment do
      ErrorMessage.unscoped {
        before = ErrorMessage.count
        ErrorMessage.destroy_all(:unresolved => false)
        after = ErrorMessage.count
        puts "Deleted #{before - after} messages for resolved errors, #{after} unresolved errors remaining"
      }
    end
  end

  namespace :api_requests do

    desc "Delete API requests, keeping last 10,000 requests"
    task :delete => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(10000).first
      unless request.nil?
        ApiRequest.delete_all(['created_at <= ?', request.created_at])
      end
      after = ApiRequest.count
      puts "Deleted #{before - after} API requests, #{after} API requests remaining"
    end
  end
end
