
task :setup_test_urls => :environment do

  # check for test mode
  config = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
  test_mode = config["test_mode"]
  if not test_mode
    exit
  end

  # get the test source url
  if config["test_hostname"].nil? or config["test_hostname"].blank?
    exit
  end

  test_source_url = config["test_hostname"]

  source = Source.find_by_name('biod')
  source.config.url = "http://#{test_source_url}/services/rest?method=usage.stats&journal=biod&doi=%{doi}"
  source.save

  # test source is not ready
  #source = Source.find_by_name('bloglines')
  #source.config.url = "http://#{test_source_url}/search?format=publicapi&apiuser=%{username}&apikey=%{password}&q=%{title}"
  #source.save

  source = Source.find_by_name('citeulike')
  source.config.url = "http://#{test_source_url}/api/posts/for/doi/%{doi}"
  source.save

  # test source is not ready
  #source = Source.find_by_name('connotea')
  #source.config.url = "http://#{test_source_url}/data/uri/%{doi_url}"
  #source.save

  source = Source.find_by_name('counter')
  source.config.url = "http://#{test_source_url}/services/rest?method=usage.stats&doi=%{doi}"
  source.save

  source = Source.find_by_name('crossref')
  source.config.url = "http://#{test_source_url}/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  source.save

  #facebook => there is a way to mock facebook data

  # test source is not ready
  #source = Source.find_by_name('mendeley')
  #source.config.url = "http://#{test_source_url}/oapi/documents/details/%{id}/?consumer_key=%{api_key}"
  #source.config.url_with_type = "http://#{test_source_url}/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}"
  #source.config.related_articles_url = "http://#{test_source_url}/oapi/documents/related/%{id}/?consumer_key=%{api_key}"
  #source.save

  source = Source.find_by_name('nature')
  source.config.url = "http://#{test_source_url}/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}"
  source.save

  # pmc data is hosted in house, update the url to point to the test pmc_usage_stats database

  # postgenomic => cannot be tested

  source = Source.find_by_name('pubmed')
  source.config.url = "http://#{test_source_url}/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"
  source.save

  source = Source.find_by_name('researchblogging')
  source.config.url = "http://#{test_source_url}/blogposts?count=100&article=doi:%{doi}"
  source.save

  # scopus => set live mode
  source = Source.find_by_name("scopus")
  source.config.live_mode = true
  source.save

  # test source is not ready
  #source = Source.find_by_name('wos')
  #source.config.url = "https://ws.isiknowledge.com/cps/xrpc"
  #source.save
end

task :undo_test_urls => :environment do

  source = Source.find_by_name('biod')
  source.config.url = "http://www.plosreports.org/services/rest?method=usage.stats&journal=biod&doi=%{doi}"
  source.save

  source = Source.find_by_name('bloglines')
  source.config.url = "http://www.bloglines.com/search?format=publicapi&apiuser=%{username}&apikey=%{password}&q=%{title}"
  source.save

  source = Source.find_by_name('citeulike')
  source.config.url = "http://www.citeulike.org/api/posts/for/doi/%{doi}"
  source.save

  source = Source.find_by_name('connotea')
  source.config.url = "http://www.connotea.orgdata/uri/%{doi_url}"
  source.save

  source = Source.find_by_name('counter')
  source.config.url = "http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}"
  source.save

  source = Source.find_by_name('crossref')
  source.config.url = "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  source.save

  # facebook

  source = Source.find_by_name('mendeley')
  source.config.url = "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}"
  source.config.url_with_type = "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}"
  source.config.related_articles_url = "http://api.mendeley.com/oapi/documents/related/%{id}/?consumer_key=%{api_key}"
  source.save

  source = Source.find_by_name('nature')
  source.config.url = "http://api.nature.com/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}"
  source.save

  source = Source.find_by_name('pmc')
  source.config.url = "http://rwc-couch01.int.plos.org:5984/pmc_usage_stats/%{doi}"
  source.save

  # postgenomic => cannot be tested

  source = Source.find_by_name('pubmed')
  source.config.url = "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"
  source.save

  source = Source.find_by_name('researchblogging')
  source.config.url = "http://#{test_source_url}/blogposts?count=100&article=doi:%{doi}"
  source.save

  source = Source.find_by_name("scopus")
  source.config.live_mode = false
  source.save

  source = Source.find_by_name('wos')
  source.config.url = "https://ws.isiknowledge.com/cps/xrpc"
  source.save
end