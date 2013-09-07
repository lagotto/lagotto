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

  desc "Queue all articles"
  task :all, [:source] => :environment do |t, args|
    if args.source.nil?
      sources = Source.active
    else
      sources = Source.active.where(name: args.source)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    sources.each do |source|
      count = source.queue_all_articles
      puts "#{count} articles for source #{source.display_name} have been queued."
    end
  end

  desc "Queue article with given DOI"
  task :one, [:doi, :source] => :environment do |t, args|
    if args.doi.nil?
      puts "DOI is required"
      exit
    end

    article = Article.find_by_doi(args.doi)
    if article.nil?
      puts "Article with doi #{args.doi} does not exist"
      exit
    end

    if args.source.nil?
      sources = Source.active
    else
      sources = Source.active.where(name: args.source)
    end

    sources.each do |source|
      rs = RetrievalStatus.find_by_article_id_and_source_id(article.id, source.id)

      if rs.nil?
        puts "Retrieval Status for article with doi #{args.doi} and source with name #{args.source} does not exist"
        exit
      end

      source.queue_article_jobs([rs.id])
      puts "Job for doi #{article.doi} and source #{source.display_name} has been queued."
    end
  end

  desc "Start job queue"
  task :start, [:source] => :environment do |t, args|
    if args.source.nil?
      sources = Source.queueable
    else
      sources = Source.queueable.where(name: args.source)
    end

    if sources.empty?
      puts "No active queueable source found."
      exit
    end

    sources.each do |source|
      source.start_queueing
      if source.queueing?
        puts "Job queue for source #{source.display_name} has been started."
      else
        puts "Job queue for source #{source.display_name} could not be started."
      end
    end
  end

  desc "Stop job queue"
  task :stop, [:source] => :environment do |t, args|
    if args.source.nil?
      sources = Source.queueable
    else
      sources = Source.queueable.where(name: args.source)
    end

    if sources.empty?
      puts "No active queueable source found."
      exit
    end

    sources.each do |source|
      source.start_waiting
      unless source.queueing?
        puts "Job queue for source #{source.display_name} has been stopped."
      else
        puts "Job queue for source #{source.display_name} could not be stopped."
      end
    end
  end

  task :pmc => :environment do

    # this rake task should be scheduled to run after pmc data import rake task runs
    source = Source.find_by_name("pmc")
    source.queue_all_articles

  end

  task :counter => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("counter")
    source.queue_all_articles

  end

  task :biod => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("biod")
    source.queue_all_articles

  end
end

