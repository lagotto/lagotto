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

namespace :queue do

  desc "Queue stale articles"
  task :stale => :environment do |t, args|
    if args.extras.empty?
      sources = Source.active
    else
      sources = Source.active.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    begin
      start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      end_date = Date.parse(ENV['END_DATE']) if ENV['END_DATE']
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing stale articles published from #{start_date} to #{end_date}." if start_date && end_date

    sources.each do |source|
      count = source.queue_all_articles(start_date: start_date, end_date: end_date)
      puts "#{count} stale articles for source #{source.display_name} have been queued."
    end
  end

  desc "Queue all articles"
  task :all => :environment do |t, args|
    if args.extras.empty?
      sources = Source.active
    else
      sources = Source.active.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    begin
      start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      end_date = Date.parse(ENV['END_DATE']) if ENV['END_DATE']
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all articles published from #{start_date} to #{end_date}." if start_date && end_date

    sources.each do |source|
      count = source.queue_all_articles(all: true, start_date: start_date, end_date: end_date)
      puts "#{count} articles for source #{source.display_name} have been queued."
    end
  end

  desc "Queue article with given uid"
  task :one, [:uid] => :environment do |t, args|
    if args.uid.nil?
      puts "#{CONFIG[:uid]} is required"
      exit
    end

    article = Article.where(CONFIG[:uid].to_sym => uid).first
    if article.nil?
      puts "Article with #{CONFIG[:uid]} #{args.uid} does not exist"
      exit
    end

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
      rs = RetrievalStatus.find_by_article_id_and_source_id(article.id, source.id)

      if rs.nil?
        puts "Retrieval Status for article with #{CONFIG[:uid]} #{args.uid} and source with name #{args.source} does not exist"
        exit
      end

      source.queue_article_jobs([rs.id], { priority: 2 })
      puts "Job for #{CONFIG[:uid]} #{article.uid} and source #{source.display_name} has been queued."
    end
  end

  task :default => :stale

end
