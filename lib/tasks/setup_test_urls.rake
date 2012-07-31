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

  source = Source.find_by_name('citeulike')
  source.config.url = "http://#{test_source_url}/api/posts/for/doi/%{doi}"
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
end

task :undo_test_urls => :environment do

  source = Source.find_by_name('citeulike')
  source.config.url = "http://www.citeulike.org/api/posts/for/doi/%{doi}"
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

  source = Source.find_by_name('pubmed')
  source.config.url = "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"
  source.save

  source = Source.find_by_name('researchblogging')
  source.config.url = "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
  source.save

  source = Source.find_by_name("scopus")
  source.config.live_mode = false
  source.save

end