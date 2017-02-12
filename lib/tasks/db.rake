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

  namespace :contributions do
    desc "Add publisher_id to all contributions"
    task :add_publisher => :environment do
      ContributionJob.perform_later
    end

    desc "Update month_id for all contributions"
    task :set_month_id => :environment do
      count = Contribution.where(month_id: nil).count
      ContributionMonthJob.perform_later
      puts "Update of month_id for #{count} contributions has been queued."
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
end
