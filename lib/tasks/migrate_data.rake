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

  default_date = '1970-01-01 00:00:00'

  # migrate articles
  puts "inserting articles"
  result = client.query("insert into #{new_db}.articles (id, doi, created_at, updated_at, pub_med, pub_med_central, published_on, title) " +
                            "select id, doi, created_at, updated_at, pub_med, pub_med_central, published_on, title from #{old_db}.articles")

  # migrate sources
  puts "inserting sources"
  result = client.query("insert into #{new_db}.sources (id, type, name, display_name, active, disable_until, disable_delay, timeout, created_at, updated_at, workers, group_id) " +
                            "select id, type, lower(type), name, active, disable_until, disable_delay, timeout, created_at, updated_at, 1, group_id from #{old_db}.sources")

  puts "migrating configuration info for bloglines, connotea, crossref, researchblogging"
  result = client.query("select username, password, type from #{old_db}.sources where type in ('Bloglines', 'Connotea', 'CrossRef', 'Researchblogging')")
  result.each do |row|
    source_name = row["type"].downcase
    source = Source.find_by_name(source_name)
    config = OpenStruct.new
    config.username = row["username"]
    config.password = row["password"]
    if source_name == 'bloglines'
      config.url = "http://www.bloglines.com/search?format=publicapi&apiuser=%{username}&apikey=%{password}&q=%{title}"
    elsif source_name == 'connotea'
      config.url = "http://www.connotea.org/data/uri/%{doi_url}"
    elsif source_name == 'crossref'
      config.url = "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
    elsif source_name == 'researchblogging'
      config.url = "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
    end
    source.config = config
    source.save
  end

  puts "migrating configuration info for facebook, mendeley, nature"
  result = client.query("select partner_id, type from #{old_db}.sources where type in ('Facebook', 'Mendeley', 'Nature')")
  result.each do |row|
    source_name = row["type"].downcase
    source = Source.find_by_name(source_name)
    config = OpenStruct.new
    config.api_key = row["partner_id"]
    if source_name == 'mendeley'
      config.url = "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}"
      config.url_with_type = "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}"
      config.related_articles_url = "http://api.mendeley.com/oapi/documents/related/%{id}/?consumer_key=%{api_key}"
    elsif source_name == 'nature'
      config.url = "http://api.nature.com/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}"
    end
    source.config = config
    source.save
  end

  puts "adding configuration info for citeulike"
  source = Source.find_by_name('citeulike')
  config = OpenStruct.new
  config.url = "http://www.citeulike.org/api/posts/for/doi/%{doi}"
  source.config = config
  source.save

  puts "adding configuration info for pubmed"
  source = Source.find_by_name('pubmed')
  config = OpenStruct.new
  config.url = "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"
  source.config = config
  source.save

  # migrate retrievals
  # citations_count => bloglines, citeulike, connotea, crossref, nature, postgenomic, pubmed, researchblogging,twitter
  # other_citations_count => scopus, wos
  # incorrect count => counter, biod, pmc, facebook, mendeley (citations_count of 1, no need to migrate them)

  puts "inserting retrievals"
  result = client.query("update #{old_db}.retrievals set created_at = '#{default_date}' where created_at is NULL")
  result = client.query("update #{old_db}.retrievals set updated_at = '#{default_date}' where updated_at is NULL")

  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, event_count, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, citations_count, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Bloglines', 'Citeulike', 'Connotea', 'CrossRef', 'Nature', 'Postgenomic', 'PubMed', 'Researchblogging', 'Twitter'))")

  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, event_count, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, other_citations_count, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Scopus', 'Wos'))")

  result = client.query("insert into #{new_db}.retrieval_statuses (id, article_id, source_id, retrieved_at, local_id, created_at, updated_at) " +
                            "select id, article_id, source_id, retrieved_at, local_id, created_at, updated_at from #{old_db}.retrievals " +
                            "where source_id in (select id from #{old_db}.sources where type in ('Counter', 'Biod', 'Pmc', 'Facebook', 'Mendeley'))")

  # insert missing retrieval status rows
  puts "inserting missing retrieval status rows"
  total_articles = 0
  results = client.query("select count(id) as total from #{old_db}.articles")
  results.each { |row| total_articles = row['total'] }

  results = client.query("select source_id, count(id) as total from #{old_db}.retrievals group by source_id")

  results.each do |row|
    source_id = row['source_id']
    num_of_articles = row['total']

    if num_of_articles != total_articles
      source = Source.find(source_id)
      created_at = source.created_at.strftime('%Y-%m-%d %H:%M:%S')
      client.query("insert into #{new_db}.retrieval_statuses (article_id, source_id, created_at, updated_at) " +
                       "select a.id, #{source_id}, '#{created_at}', '#{created_at}' from #{old_db}.articles a where not exists " +
                       "(select * from #{old_db}.retrievals r where r.article_id = a.id and r.source_id = #{source_id})")
    end
  end

  # migrate groups
  puts "inserting groups"
  result = client.query("update #{old_db}.groups set created_at = '#{default_date}' where created_at is NULL")
  result = client.query("update #{old_db}.groups set updated_at = '#{default_date}' where updated_at is NULL")

  result = client.query("insert into #{new_db}.groups (id, name, created_at, updated_at) " +
                            "select id, name, created_at, updated_at from #{old_db}.groups;")

  # migrate histories
  puts "inserting histories"
  total = 0
  result = client.query("select count(id) as total from #{old_db}.histories")
  result.each do |row|
    total = row["total"]
  end

  limit = 100000
  offset = 0
  while offset < total
    puts "inserting history rows: offset #{offset} limit #{limit} total #{total}"

    result = client.query ("insert into #{new_db}.retrieval_histories (id, retrieval_status_id, article_id, source_id, retrieved_at, event_count, status, created_at, updated_at) " +
      "select h.id, h.retrieval_id, r.article_id, r.source_id, h.updated_at, h.citations_count, 'SUCCESS', h.created_at, h.updated_at from #{old_db}.histories h, #{old_db}.retrievals r where h.retrieval_id = r.id order by h.id limit #{offset},#{limit}")

    offset += limit

  end

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
      args.source_name == "postgenomic" || args.source_name == "pubmed" || args.source_name == "citeulike" ||
      args.source_name == "facebook" || args.source_name == "crossref" || args.source_name == "researchblogging"

  else
    puts "Source name has be to one of the following: nature, bloglines, connotea, postgenomic, pubmed, citeulike, " +
             "facebook, crossref, and researchblogging"
    exit
  end

  source = Source.find_by_name(args.source_name)
  if source.nil?
    puts "Incorrect source name was passed in.  Try again."
    exit
  end
  puts "Source name #{source.name}"

  YAML::ENGINE.yamler= 'syck'

  puts "Start: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

  results = client.query("select c.id, a.doi, a.pub_med, c.retrieval_id, r.retrieved_at, r.local_id, c.uri, c.details " +
                             "from #{old_db}.sources s, #{old_db}.retrievals r, #{old_db}.citations c, #{old_db}.articles a " +
                             "where s.type = '#{source.type}' " +
                             "and r.source_id = s.id " +
                             "and c.retrieval_id = r.id " +
                             "and a.id = r.article_id " +
                             "order by c.retrieval_id ", :application_timezone => :utc, :database_timezone => :utc)

  current_retrieval_id = nil
  doi = nil
  pub_med = nil
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
        if source.name == "pubmed"
          data[:events_url] = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=#{pub_med}"

        elsif source.name == "citeulike"
          data[:events_url] = "http://www.citeulike.org/doi/#{doi}"

        elsif source.name == "researchblogging"
          data[:events_url] = "http://researchblogging.org/post-search/list?article=#{Addressable::URI.encode(doi)}"

        else
          data[:events_url] = nil
        end
        data[:doc_type] = "current"

        data_rev = save_alm_data(nil, data, "#{source.name}:#{Addressable::URI.encode(doi)}")
        retrieval_status = RetrievalStatus.find(current_retrieval_id)
        retrieval_status.data_rev = data_rev

        if source.name == "facebook"
          total = 0
          events.each do | event |
            total += event[:total_count]
          end
          retrieval_status.event_count = total
        end

        retrieval_status.save
      end

      current_retrieval_id = row["retrieval_id"]
      events = []
    end

    if source.name == "nature"
      YAML::load(row["details"])
      event = YAML.load(row["details"])
      events << {:event => event[:post], :event_url => row["uri"]}

    elsif source.name == "pubmed"
      event = row["uri"]
      events << {:event => event[event.rindex("=") + 1,event.size], :event_url =>  row["uri"]}

    elsif source.name == "citeulike"
      event = YAML.load(row["details"])
      url = event.delete(:uri)
      event[:link] = {:url => url}
      events << {:event => event, :event_url => row["uri"]}

    elsif source.name == "facebook"
      event = YAML.load(row["details"])
      event.delete(:uri)
      events << event

    elsif source.name == "crossref"
      event = YAML.load(row["details"])
      event.delete(:uri)
      contributors = []
      old_contributors = event.delete(:contributors)
      unless old_contributors.nil?
        old_contributors = old_contributors.split(",")
        old_contributors.each do |contributor|
          name = contributor.split(" ")
          given_name = name.pop
          surname = name.join(" ")
          contributors << {:first_author => false, :given_name => given_name, :surname => surname}
        end
        contributors[0][:first_author] = true
        event[:contributors] = contributors
      end

      events << {:event => event, :event_url => row["uri"]}

    elsif source.name == "researchblogging"
      event = YAML.load(row["details"])
      event.delete(:uri)
      event = event[:details]
      event[:post_title] = event.delete(:title)
      event[:blog_name] = event.delete(:name)
      event[:blogger_name] = event.delete(:blogger_name)
      event[:published_date] = event.delete(:publishdate)
      event[:received_date] = event.delete(:receiveddate)
      event[:post_URL] = row["uri"]

      events << {:event => event, :event_url => row["uri"]}
    end

    doi = row["doi"]
    pub_med = row["pub_med"]
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
    if source.name == "pubmed"
      data[:events_url] = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=#{pub_med}"

    elsif source.name == "citeulike"
      data[:events_url] = "http://www.citeulike.org/doi/#{doi}"

    elsif source.name == "researchblogging"
      data[:events_url] = "http://researchblogging.org/post-search/list?article=#{Addressable::URI.encode(doi)}"

    else
      data[:events_url] = nil
    end
    data[:doc_type] = "current"

    data_rev = save_alm_data(nil, data, "#{source.name}:#{Addressable::URI.encode(doi)}")
    retrieval_status = RetrievalStatus.find(current_retrieval_id)
    retrieval_status.data_rev = data_rev

    if source.name == "facebook"
      total = 0
      events.each do | event |
        total += event[:total_count]
      end
      retrieval_status.event_count = total
    end

    retrieval_status.save
  end

  puts "Done: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

end

task :migrate_retrieval_data_with_count, [:source_name, :old_db] => :environment do |t, args|
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

  if args.source_name == "scopus" || args.source_name == "wos"
  else
    puts "Source name has be to one of the following: scopus and wos"
    exit
  end

  source = Source.find_by_name(args.source_name)
  if source.nil?
    puts "Incorrect source name was passed in.  Try again."
    exit
  end
  puts "Source name #{source.name}"

  puts "Start: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

  results = client.query("select a.doi, r.id, r.retrieved_at, r.other_citations_count, r.local_id " +
                             "from #{old_db}.sources s, #{old_db}.retrievals r, #{old_db}.articles a " +
                             "where s.type = '#{source.type}' " +
                             "and r.source_id = s.id " +
                             "and a.id = r.article_id " +
                             "and r.other_citations_count > 0 " +
                             "order by r.other_citations_count desc", :application_timezone => :utc, :database_timezone => :utc)

  results.each do |row|

    data = {}
    data[:doi] = row["doi"]
    data[:retrieved_at] = row["retrieved_at"]
    data[:source] = source.name
    data[:events] = row["other_citations_count"].to_s
    data[:events_url] = events_url
    data[:doc_type] = "current"

    data_rev = save_alm_data(nil, data, "#{source.name}:#{Addressable::URI.encode(row["doi"])}")
    retrieval_status = RetrievalStatus.find(row["id"])
    retrieval_status.data_rev = data_rev
    retrieval_status.save
  end

  puts "Done: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

end
