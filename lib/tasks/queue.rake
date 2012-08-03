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

  task :citeulike => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("citeulike")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :crossref => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("crossref")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :nature => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("nature")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :mendeley => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("mendeley")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :researchblogging => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("researchblogging")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :pubmed => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("pubmed")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :facebook => :environment do

    # this rake task is setup to run forever
    loop do
      source = Source.find_by_name("facebook")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :single_job, [:doi, :source] => :environment do |t, args|
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
      puts "Source is required"
      exit
    end

    source = Source.find_by_name(args.source)
    if source.nil?
      puts "Source with name #{args.source} does not exist"
      exit
    end

    rs = RetrievalStatus.find_by_article_id_and_source_id(article.id, source.id)
    source.queue_article_job(rs)

    puts "Job for doi #{article.doi} and source #{source.display_name} has been queued."
  end

  task :all_jobs, [:source] => :environment do |t, args|
    if args.source.nil?
      puts "Source is required"
      exit
    end

    source = Source.find_by_name(args.source)
    if source.nil?
      puts "Source with name #{args.source} does not exist"
      exit
    end

    source.queue_all_articles

    puts "Jobs for all the articles for source #{source.display_name} have been queued."
  end
end

