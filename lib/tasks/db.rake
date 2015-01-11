namespace :db do
  namespace :articles do
    desc "Bulk-load works from standard input"
    task :load => :environment do
      begin
        input = []
        $stdin.each_line { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) } unless $stdin.tty?
        number = input.length
        fail Errno::ENOENT, "No works to import." if input.empty?
      rescue Errno::ENOENT => e
        puts e.message
        exit
      end

      member = ENV['MEMBER']
      if member.blank? && Publisher.pluck(:member_id).length == 1
        # if we have only configured a single publisher
        member = Publisher.pluck(:member_id).join(",")
      end

      # import in batches of 1,000 works
      input.each_slice(1000) do |batch|
        import = FileImport.new(file: batch, member: member)
        import.queue_work_import
      end
      puts "Started import of #{number} works in the background..."
    end
  end

  namespace :works do
    namespace :import do
      desc "Import works from Crossref REST API"
      task :crossref => :environment do
        # only run if configuration option ENV['IMPORT'],
        # or ENV['MEMBER'] and/or ENV['SAMPLE'] are provided
        exit unless ENV['IMPORT'].present? || ENV['MEMBER'].present? || ENV['SAMPLE'].present?

        case ENV['IMPORT'].to_s.downcase
        when "member"
          member = ENV['MEMBER'].presence || Publisher.pluck(:member_id).join(",")
          sample = ENV['SAMPLE'].presence && ENV['SAMPLE'].to_i
        when "member_sample"
          member = ENV['MEMBER'].presence || Publisher.pluck(:member_id).join(",")
          sample = (ENV['SAMPLE'].presence || 20).to_i
        when "sample"
          member = ENV['MEMBER'].presence
          sample = (ENV['SAMPLE'].presence || 20).to_i
        when "crossref"
          member = ENV['MEMBER'].presence
          sample = ENV['SAMPLE'].presence && ENV['SAMPLE'].to_i
        end

        import = CrossrefImport.new(
          from_update_date: ENV['FROM_UPDATE_DATE'],
          until_update_date: ENV['UNTIL_UPDATE_DATE'],
          from_pub_date: ENV['FROM_PUB_DATE'],
          until_pub_date: ENV['UNTIL_PUB_DATE'],
          type: ENV['TYPE'],
          member: member,
          issn: ENV['ISSN'],
          sample: sample)
        number = ENV['SAMPLE'] || import.total_results
        if number.to_i > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end

      desc "Import works from DataCite API"
      task :datacite => :environment do
        case ENV['IMPORT'].to_s.downcase
        when "member"
          member = ENV['MEMBER'].presence || Publisher.pluck(:name).join(",")
        else
          member = ENV['MEMBER'].presence
        end

        import = DataciteImport.new(
          from_update_date: ENV['FROM_UPDATE_DATE'],
          until_update_date: ENV['UNTIL_UPDATE_DATE'],
          from_pub_date: ENV['FROM_PUB_DATE'],
          until_pub_date: ENV['UNTIL_PUB_DATE'],
          type: ENV['TYPE'],
          member: member)
        number = import.total_results
        if number > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end

      desc "Import works from PLOS Search API"
      task :plos => :environment do
        import = PlosImport.new(
          from_pub_date: ENV['FROM_PUB_DATE'],
          until_pub_date: ENV['UNTIL_PUB_DATE'])
        number = import.total_results
        if number > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end

      desc "Import works from DataONE Solr API"
      task :dataone => :environment do
        import = DataoneImport.new(
          from_pub_date: ENV['FROM_PUB_DATE'],
          until_pub_date: ENV['UNTIL_PUB_DATE'],
          from_update_date: ENV['FROM_UPDATE_DATE'],
          until_update_date: ENV['UNTIL_UPDATE_DATE'])
        number = import.total_results
        if number > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end

      desc "Import works from CSL JSON file"
      task :csl => :environment do
        begin
          filepath = "#{Rails.root}/#{ENV['FILE']}"
        rescue Errno::ENOENT, Errno::EISDIR => e
          puts e.message
          exit
        end

        member = ENV['MEMBER']
        if member.blank? && Publisher.pluck(:member_id).length == 1
          # if we have only configured a single publisher
          member = Publisher.pluck(:member_id).join(",")
        end

        import = CslImport.new(filepath: filepath, member: member)
        number = import.total_results
        if number > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end

      desc "Import works from Sciencetoolbox JSON file"
      task :sciencetoolbox => :environment do
        begin
          filepath = "#{Rails.root}/#{ENV['FILE']}"
        rescue Errno::ENOENT, Errno::EISDIR => e
          puts e.message
          exit
        end

        member = ENV['MEMBER']
        if member.blank? && Publisher.pluck(:member_id).length == 1
          # if we have only configured a single publisher
          member = Publisher.pluck(:member_id).join(",")
        end

        import = SciencetoolboxImport.new(filepath: filepath, member: member)
        number = import.total_results
        if number > 0
          import.queue_work_import
          puts "Started import of #{number} works in the background..."
        else
          puts "No works to import."
        end
      end
    end

    desc "Delete works"
    task :delete => :environment do
      if ENV['MEMBER'].blank?
        puts "Please use MEMBER environment variable. No work deleted."
        exit
      end

      DeleteWorkJob.perform_later(ENV['MEMBER'])

      if ENV['MEMBER'] == "all"
        puts "Started deleting all works in the background..."
      else
        puts "Started deleting all works from MEMBER #{ENV['MEMBER']} in the background..."
      end
    end

    desc "Add missing sources"
    task :add_sources, [:date] => :environment do |_, args|
      if args.date.nil?
        puts "Date in format YYYY-MM-DD required"
        exit
      end

      works = Work.where("published_on >= ?", args.date)

      if args.extras.empty?
        sources = Source.all
      else
        sources = Source.where("name in (?)", args.extras)
      end

      retrieval_statuses = []
      works.each do |work|
        sources.each do |source|
          retrieval_status = RetrievalStatus.where(work_id: work.id, source_id: source.id).find_or_initialize
          if retrieval_status.new_record?
            retrieval_status.save!
            retrieval_statuses << retrieval_status
          end
        end
      end

      puts "#{retrieval_statuses.count} retrieval status(es) added for #{sources.count} source(s) and #{works.count} works"
    end

    desc "Remove all HTML and XML tags from work titles"
    task :sanitize_title => :environment do
      Work.all.each { |work| work.save }
      puts "#{Work.count} work titles sanitized"
    end

    desc "Load pids from persistent identifiers"
    task :load_pids => :environment do
      Work.where("doi IS NOT NULL").update_all("pid = doi")
      Work.where("doi IS NOT NULL").update_all(pid_type: "doi")
      puts "#{Work.count} work pids loaded"
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
        puts "Adding date parts for all works published since #{start_date}."
        works = Work.where("published_on >= ?", start_date)
      else
        works = Work.all
      end

      works.each do |work|
        work.update_date_parts
        work.save
      end
      puts "Date parts for #{works.count} works added"
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

  namespace :publishers do

    desc "Create publisher"
    task :create => :environment do
      begin
        fail ArgumentError, "Please provide publisher name via ENV['NAME']" if ENV['NAME'].blank?
        fail ArgumentError, "Please provide publisher title via ENV['TITLE']" if ENV['TITLE'].blank?

        publisher = Publisher.create!(name: ENV['NAME'],
                                      title: ENV['TITLE'],
                                      member_id: ENV['NAME'].to_i(36),
                                      prefixes: [],
                                      other_names: [])
        puts "Publisher #{publisher.title} created"
      rescue ArgumentError => e
        puts e.message
        exit
      end
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
