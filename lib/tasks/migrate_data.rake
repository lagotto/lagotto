require 'mysql2'
require 'source_helper'

task :migrate_data, [:old_db] => :environment do |t, args|

  puts "Start: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

  # need a username and password that will work on both new and old alm databases
  db_config = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

  if db_config["host"].nil? || db_config["username"].nil? || db_config["password"].nil? || db_config["database"].nil?
    puts "Database configuration is missing.  Try again"
    exit
  end

  puts "Host: #{db_config["host"]}, Username: #{db_config["username"]}, Password: #{db_config["password"]}"
  client = Mysql2::Client.new(:host => db_config["host"],
                              :username => db_config["username"],
                              :password => db_config["password"])

  # get old database name
  if args.old_db.nil?
    puts "Old database name is required"
    exit
  end
  puts "Old database name: #{args.old_db}"

  old_db = args.old_db
  new_db = db_config["database"]

  # TODO migrate groups
  # TODO migrate users

  # migrate articles
  puts "inserting articles"
  result = client.query("insert into #{new_db}.articles (id, doi, created_at, updated_at, pub_med, pub_med_central, published_on, title) " +
                            "select id, doi, created_at, updated_at, pub_med, pub_med_central, published_on, title from #{old_db}.articles")

  #migrate sources
  puts "inserting sources"
  result = client.query("insert into #{new_db}.sources (id, type, name, display_name, active, disable_until, disable_delay, timeout, created_at, updated_at, workers) " +
                            "select id, type, lower(type), name, active, disable_until, disable_delay, timeout, created_at, updated_at, 1 from #{old_db}.sources")

  puts "migrating configuration info for bloglines, connotea, crossref, researchblogging"
  result = client.query("select username, password, type from #{old_db}.sources where type in ('Bloglines', 'Connotea', 'CrossRef', 'Researchblogging')")
  result.each do |row|
    source = Source.find_by_name(row["type"].downcase)
    config = OpenStruct.new
    config.username = row["username"]
    config.password = row["password"]
    source.config = config
    source.save
  end

  puts "migrating configuration info for facebook, mendeley, nature"
  result = client.query("select partner_id, type from #{old_db}.sources where type in ('Facebook', 'Mendeley', 'Nature')")
  result.each do |row|
    source = Source.find_by_name(row["type"].downcase)
    config = OpenStruct.new
    config.api_key = row["partner_id"]
    source.config = config
    source.save
  end

  puts "migrating configuration info for pmc"
  result = client.query("select url, type from #{old_db}.sources where type in ('Pmc')")
  result.each do |row|
    source = Source.find_by_name(row["type"].downcase)
    config = OpenStruct.new
    config.url = row["url"]
    source.config = config
    source.save
  end

  puts "migrating configuration info for scopus"
  result = client.query("select username, live_mode, salt, partner_id, type from #{old_db}.sources where type in ('Scopus')", :cast_booleans => true)
  result.each do |row|
    source = Source.find_by_name(row["type"].downcase)
    config = OpenStruct.new
    config.username = row["username"]
    config.live_mode = row["live_mode"]
    config.salt = row["salt"]
    config.partner_id = row["partner_id"]
    source.config = config
    source.save
  end

  #migrate retrievals
  #citations_count => bloglines, citeulike, connotea, crossref, nature, postgenomic, pubmed, researchblogging,
  #other_citations_count => scopus, wos
  #incorrect count => counter, biod, pmc, facebook, mendeley (citations_count of 1, no need to migrate them)

  puts "inserting retrievals"
  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, event_count, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, citations_count, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Bloglines', 'Citeulike', 'Connotea', 'CrossRef', 'Nature', 'Postgenomic', 'PubMed', 'Researchblogging'))")

  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, event_count, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, other_citations_count, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Scopus', 'Wos'))")

  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Counter', 'Biod', 'Pmc', 'Facebook', 'Mendeley'))")

  # migrate histories
  puts "inserting histories #{result.inspect}"
  total = 0
  result = client.query("select count(id) as total from #{old_db}.histories")
  result.each do |row|
    total = row["total"]
  end

  limit = 100000
  offset = 0
  while offset < total
    puts "inserting history rows: offset #{offset} limit #{limit} total #{total}"

    result = client.query ("insert into #{new_db}.retrieval_histories (id, article_id, source_id, retrieved_at, event_count) " +
      "select h.id, r.article_id, r.source_id, h.updated_at, h.citations_count from #{old_db}.histories h, #{old_db}.retrievals r where h.retrieval_id = r.id order by h.id limit #{offset},#{limit}")

    offset += limit

  end

  # migrate retrieval data for nature (has api limit)
  # migrate retrieval data for bloglines, connotea and postgenomic (they are disabled)
  # the rest of the retrieval data can be retrieved

  Rake::Task["migrate_retrieval_data"].invoke("nature", old_db)
  Rake::Task["migrate_retrieval_data"].invoke("bloglines", old_db)
  Rake::Task["migrate_retrieval_data"].invoke("connotea", old_db)
  Rake::Task["migrate_retrieval_data"].invoke("postgenomic", old_db)

  puts "End: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
end

task :migrate_retrieval_data, [:source_name, :old_db] => :environment do |t, args|
  include SourceHelper

  # get database connection information
  db_config = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

  if db_config["host"].nil? || db_config["username"].nil? || db_config["password"].nil?
    puts "Database configuration is missing.  Try again"
    exit
  end

  puts "Host: #{db_config["host"]}, Username: #{db_config["username"]}, Password: #{db_config["password"]}"
  client = Mysql2::Client.new(:host => db_config["host"],
                              :username => db_config["username"],
                              :password => db_config["password"])

  # get old database name
  if args.old_db.nil?
    puts "Old database name is required"
    exit
  end
  puts "Old database name: #{args.old_db}"
  old_db = args.old_db

  if args.source_name == "nature" || args.source_name == "bloglines" || args.source_name == "connotea" ||
      args.source_name == "postgenomic"

  else
    puts "Source name has be to one of the following: nature, bloglines, connotea, and postgenomic"
    exit
  end

  source = Source.find_by_name(args.source_name)
  if source.nil?
    puts "Incorrect source name was passed in.  Try again."
    exit
  end
  puts "Source name #{source.name}"

  puts "Start: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

  results = client.query("select c.id, a.doi, c.retrieval_id, r.retrieved_at, r.local_id, c.uri, c.details " +
                             "from #{old_db}.sources s, #{old_db}.retrievals r, #{old_db}.citations c, #{old_db}.articles a " +
                             "where s.type = '#{source.type}' " +
                             "and r.source_id = s.id " +
                             "and c.retrieval_id = r.id " +
                             "and a.id = r.article_id " +
                             "order by c.retrieval_id ", :application_timezone => :utc, :database_timezone => :utc)

  current_retrieval_id = nil
  doi = nil
  retrieved_at = nil
  local_id = nil

  events = []

  results.each do |row|

    if current_retrieval_id != row["retrieval_id"]
      if events.length > 0
        data = {}
        data[:doi] = doi
        data[:retrieved_at] = retrieved_at
        data[:source] = source.name
        data[:events] = events
        if source.name == "connotea"
          data[:events_url] = "http://www.connotea.org/uri/#{local_id}"
        elsif source.name == "postgenomic"
          data[:events_url] = "http://postgenomic.com/paper.php?doi=#{CGI.escape(doi)}"
        else
          data[:events_url] = nil
        end

        data_rev = save_alm_data(nil, data, "#{source.name}:#{CGI.escape(doi)}")
        retrieval_status = RetrievalStatus.find(current_retrieval_id)
        retrieval_status.data_rev = data_rev
        retrieval_status.save
      end

      current_retrieval_id = row["retrieval_id"]
      events = []
    end

    if source.name == "nature"
      YAML::load(row["details"])
      event = YAML.load(row["details"])
      events << {:event => event[:post], :event_url => row["uri"]}

    elsif source.name == "bloglines"
      event = YAML.load(row["details"])
      event.delete(:uri)
      events << {:event => event, :event_url => row["uri"]}

    elsif source.name == "postgenomic"
      begin
        event = YAML.load(row["details"].inspect)
        event.delete(:uri)
        events << {:event => event, :event_url => row["uri"]}
      rescue => e
        puts "citation.id #{row["id"]}, article.doi #{row["doi"]}: failed to load the yaml data."
      end

    elsif source.name == "connotea"
      event = YAML.load(row["details"])
      events << {:event => event[:uri], :event_url => row["uri"]}
    end

    doi = row["doi"]
    retrieved_at = row["retrieved_at"]
    local_id = row["local_id"]
  end

  # save the last one
  if events.length > 0
    data = {}
    data[:doi] = doi
    data[:retrieved_at] = retrieved_at
    data[:source] = source.name
    data[:events] = events
    if source.name == "connotea"
      data[:events_url] = "http://www.connotea.org/uri/#{local_id}"
    elsif source.name == "postgenomic"
      data[:events_url] = "http://postgenomic.com/paper.php?doi=#{CGI.escape(doi)}"
    else
      data[:events_url] = nil
    end

    data_rev = save_alm_data(nil, data, "#{source.name}:#{CGI.escape(doi)}")
    retrieval_status = RetrievalStatus.find(current_retrieval_id)
    retrieval_status.data_rev = data_rev
    retrieval_status.save
  end

  puts "Done: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

end

