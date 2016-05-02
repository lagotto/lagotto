namespace :db do
  namespace :works do
    desc "Delete works"
    task :delete => :environment do
      if ENV['PUBLISHER_ID'].blank?
        puts "Please use PUBLISHER_ID environment variable. No work deleted."
        exit
      end

      if ENV['SOURCE_ID'].blank?
        puts "Please use SOURCE_ID environment variable. No work deleted."
        exit
      end

      DeleteWorkJob.perform_later(publisher_id: ENV['PUBLISHER_ID'], source_id: ENV['SOURCE_ID'])

      if ENV['PUBLISHER_ID'] == "all" && ENV['SOURCE_ID'] == "all"
        puts "Started deleting all works in the background..."
      elsif ENV['PUBLISHER_ID'] == "all"
        puts "Started deleting all works for source #{ENV['SOURCE_ID']} in the background..."
      elsif ENV['SOURCE_ID'] == "all"
        puts "Started deleting all works from publisher #{ENV['PUBLISHER_ID']} in the background..."
      else
        puts "Started deleting all works from publisher #{ENV['PUBLISHER_ID']} for source #{ENV['SOURCE_ID']} in the background..."
      end
    end

    desc "Delete canonical url"
    task :delete_url => :environment do
      DeleteCanonicalUrlJob.perform_later
      puts "Started deleting all canonical urls in the background..."
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

    desc "Change pids to URLs"
    task :change_pids => :environment do
      Work.where("pid_type = 'doi'").update_all("pid = CONCAT('http://doi.org/', doi)")
      Work.where("pid_type = 'pmid'").update_all("pid = CONCAT('http://www.ncbi.nlm.nih.gov/pubmed/', pmid)")
      Work.where("pid_type = 'pmcid'").update_all("pid = CONCAT('http://www.ncbi.nlm.nih.gov/pmc/articles/PMC', pmcid)")
      Work.where("pid_type = 'arxiv'").update_all("pid = CONCAT('http://arxiv.org/abs/', arxiv)")
      Work.where("pid_type = 'ark'").update_all("pid = CONCAT('http://n2t.net/', ark)")
      puts "#{Work.count} work pids changed"
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

    desc "Update issued_at dateime"
    task :issued_at => :environment do
      collection = Work.where("issued_at < '1970-01-02'")
      collection.update_all("issued_at = published_on")
      puts "#{collection.count} works changed"
    end
  end

  namespace :notifications do
    desc "Resolve all notifications with level INFO and WARN"
    task :resolve => :environment do
      Notification.unscoped do
        before = Notification.count
        Notification.where("level < 3").update_all(unresolved: false)
        after = Notification.count
        puts "Deleted #{before - after} resolved notifications, #{after} unresolved notifications remaining"
      end
    end

    desc "Delete all resolved notifications"
    task :delete => :environment do
      Notification.unscoped do
        before = Notification.count
        Notification.where(:unresolved => false).delete_all
        after = Notification.count
        puts "Deleted #{before - after} resolved notifications, #{after} unresolved notifications remaining"
      end
    end
  end

  namespace :api_requests do

    desc "Delete API requests, keeping last 100,000 requests"
    task :delete => :environment do
      request = ApiRequest.order("created_at DESC").offset(100000).first
      if request.present?
        count = ApiRequest.where("created_at <= ?", request.created_at).delete_all
        puts "Deleted #{count} API requests"
      else
        puts "Deleted 0 API requests"
      end
    end
  end

  namespace :api_responses do

    desc "Delete all API responses older than 24 hours"
    task :delete => :environment do
      count = ApiResponse.where("created_at < ?", Time.zone.now - 1.day).delete_all
      puts "Deleted #{count} API responses"
    end
  end

  namespace :changes do

    desc "Delete all changes older than 24 hours"
    task :delete => :environment do
      count = Change.where("created_at < ?", Time.zone.now - 1.day).delete_all
      puts "Deleted #{count} changes"
    end
  end

  namespace :deposits do

    desc "Delete all completed deposits older than 7 days"
    task :delete => :environment do
      count = Deposit.where("state = ?", 3).where("created_at < ?", Time.zone.now - 7.days).delete_all
      puts "Deleted #{count} completed deposits"
    end

    desc "Migrate deposits to registration agency model"
    task :migrate => :environment do
      count = Deposit.where(registration_agency_id: nil).where(source_id: "crossref_datacite").update_all(registration_agency_id: "datacite")
      puts "Updated #{count} deposits for source Crossref (DataCite)"

      count = Deposit.where(registration_agency_id: nil).where(source_id: "datacite_crossref").update_all(registration_agency_id: "crossref")
      puts "Updated #{count} deposits for source DataCite (Crossref)"

      count = Deposit.where(registration_agency_id: nil).where(source_id: "datacite_related").update_all(registration_agency_id: "datacite")
      puts "Updated #{count} deposits for source DataCite (RelatedIdentifier)"

      count = Deposit.where(registration_agency_id: nil).where(source_id: "datacite_orcid").update_all(registration_agency_id: "datacite")
      puts "Updated #{count} deposits for source DataCite (ORCID)"

      count = Deposit.where(registration_agency_id: nil).where(source_id: "datacite_github").update_all(registration_agency_id: "github")
      puts "Updated #{count} deposits for source DataCite (GitHub)"

      count = Deposit.where(registration_agency_id: nil).where(source_id: "github").update_all(registration_agency_id: "github")
      puts "Updated #{count} deposits for source GitHub"
    end
  end

  namespace :registration_agencies do

    desc "Migrate works, prefixes and publishers to registration agency model"
    task :migrate => :environment do
      RegistrationAgency.find_each do |ra|
        count = Work.where(registration_agency_id: nil).where("registration_agency = ?", ra.name).update_all(registration_agency_id: ra.id)
        puts "Updated #{count} works for registration agency #{ra.title}"

        count = Prefix.where(registration_agency_id: 0).where("registration_agency = ?", ra.name).update_all(registration_agency_id: ra.id)
        puts "Updated #{count} prefixes for registration agency #{ra.title}"

        count = Publisher.where(registration_agency_id: 0).where("registration_agency = ?", ra.name).update_all(registration_agency_id: ra.id)
        puts "Updated #{count} publishers for registration agency #{ra.title}"
      end
    end
  end

  namespace :agents do

    desc "Activate agents"
    task :activate => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.inactive
      else
        agents = Agent.inactive.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No inactive agent found."
        exit
      end

      agents.each do |agent|
        agent.activate
        if agent.waiting?
          puts "Agent #{agent.title} has been activated and is now waiting."
        else
          puts "Agent #{agent.title} could not be activated."
        end
      end
    end

    desc "Inactivate agents"
    task :inactivate => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.active
      else
        agents = Agent.active.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No active agent found."
        exit
      end

      agents.each do |agent|
        agent.inactivate
        if agent.inactive?
          puts "Agent #{agent.title} has been inactivated."
        else
          puts "Agent #{agent.title} could not be inactivated."
        end
      end
    end

    desc "Install agents"
    task :install => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.available
      else
        agents = Agent.available.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No available agent found."
        exit
      end

      agents.each do |agent|
        agent.install
        unless agent.available?
          puts "Agent #{agent.title} has been installed."
        else
          puts "Agent #{agent.title} could not be installed."
        end
      end
    end

    desc "Uninstall agents"
    task :uninstall => :environment do |_, args|
      if args.extras.empty?
        puts "No agent name provided."
        exit
      else
        agents = Agent.installed.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No installed agent found."
        exit
      end

      agents.each do |agent|
        agent.uninstall
        if agent.available?
          puts "Agent #{agent.title} has been uninstalled."
        elsif agent.retired?
          puts "Agent #{agent.title} has been retired."
        else
          puts "Agent #{agent.title} could not be uninstalled."
        end
      end
    end
  end
end
