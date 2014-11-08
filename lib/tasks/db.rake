# encoding: UTF-8

namespace :db do
  namespace :articles do
    desc "Bulk-load articles from Crossref API"
    task :import => :environment do
      # only run if configuration option ENV['IMPORT'],
      # or ENV['MEMBER'] and/or ENV['SAMPLE'] are provided
      exit unless ENV['IMPORT'] || ENV['MEMBER'] || ENV['SAMPLE']

      case ENV['IMPORT']
      when "MEMBER"
        member = ENV['MEMBER'] || Publisher.pluck(:crossref_id).join(",")
        sample = ENV['SAMPLE']
      when "MEMBER_SAMPLE"
        member = ENV['MEMBER'] || Publisher.pluck(:crossref_id).join(",")
        sample = ENV['SAMPLE'] || 20
      when "SAMPLE"
        member = ENV['MEMBER']
        sample = ENV['SAMPLE'] || 20
      else
        member = ENV['MEMBER']
        sample = ENV['SAMPLE']
      end

      options = { from_update_date: ENV['FROM_UPDATE_DATE'],
                  until_update_date: ENV['UNTIL_UPDATE_DATE'],
                  from_pub_date: ENV['FROM_PUB_DATE'],
                  until_pub_date: ENV['UNTIL_PUB_DATE'],
                  type: ENV['TYPE'],
                  member: member,
                  issn: ENV['ISSN'],
                  sample: sample }
      import = Import.new(options)
      number = ENV['SAMPLE'] || import.total_results
      import.queue_article_import if number.to_i > 0
      puts "Started import of #{number} articles in the background..."
    end

    desc "Bulk-load articles from standard input"
    task :load => :environment do
      input = []
      $stdin.each_line { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) } unless $stdin.tty?

      number = input.length
      member = ENV['MEMBER']
      if member.nil? && Publisher.pluck(:crossref_id).length == 1
        # if we have only configured a single publisher
        member = Publisher.pluck(:crossref_id).first
      end

      if number > 0
        # import in batches of 1,000 articles
        input.each_slice(1000) do |batch|
          import = Import.new(file: batch, member: member)
          import.queue_article_import
        end
        puts "Started import of #{number} articles in the background..."
      else
        puts "No articles to import."
      end
    end

    desc "Delete articles"
    task :delete => :environment do
      if ENV['MEMBER'].blank?
        puts "Please use MEMBER environment variable. No article deleted."
        exit
      end

      Article.queue_article_delete(ENV['MEMBER'])
      if ENV['MEMBER'] == "all"
        puts "Started deleting all articles in the background..."
      else
        puts "Started deleting all articles from MEMBER #{ENV['MEMBER']} in the background..."
      end
    end

    desc "Add missing sources"
    task :add_sources, [:date] => :environment do |_, args|
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
          retrieval_status = RetrievalStatus.where(article_id: article.id, source_id: source.id).find_or_initialize
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
    desc "Resolve all alerts with level INFO and WARN"
    task :resolve => :environment do
      Alert.unscoped do
        before = Alert.count
        Alert.where("level < 3").update_all(unresolved: false)
        after = Alert.count
        puts "Deleted #{before - after} resolved alerts, #{after} unresolved alerts remaining"
      end
    end

    desc "Delete all resolved alerts"
    task :delete => :environment do
      Alert.unscoped do
        before = Alert.count
        Alert.where(:unresolved => false).delete_all
        after = Alert.count
        puts "Deleted #{before - after} resolved alerts, #{after} unresolved alerts remaining"
      end
    end
  end

  namespace :api_requests do

    desc "Delete API requests, keeping last 100,000 requests"
    task :delete => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(100000).first
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
    task :activate => :environment do |_, args|
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
    task :inactivate => :environment do |_, args|
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
    task :install => :environment do |_, args|
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
    task :uninstall => :environment do |_, args|
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
