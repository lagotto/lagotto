# encoding: UTF-8

namespace :queue do

  desc "Queue stale articles"
  task :stale => :environment do |_, args|
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
  task :all => :environment do |_, args|
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
  task :one, [:uid] => :environment do |_, args|
    if args.uid.nil?
      puts "#{ENV['UID']} is required"
      exit
    end

    article = Article.where(ENV['UID'].to_sym => args.uid).first
    if article.nil?
      puts "Article with #{ENV['UID']} #{args.uid} does not exist"
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
      rs = RetrievalStatus.where(article_id: article.id, source_id: source.id).first

      if rs.nil?
        puts "Retrieval Status for article with #{ENV['UID']} #{args.uid} and source with name #{args.source} does not exist"
        exit
      end

      source.queue_article_jobs([rs.id], priority: 2)
      puts "Job for #{ENV['UID']} #{article.uid} and source #{source.display_name} has been queued."
    end
  end

  task :default => :stale

end
