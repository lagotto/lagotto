default[:alm][:name] = "alm"
default[:alm][:host] = "localhost"
default[:alm][:environment] = "development"
default[:alm][:useragent] = "Article-Level Metrics"
default[:alm][:api_key] = nil
default[:alm][:admin] = { :username => "articlemetrics", :name => "Admin", :email => "admin@example.com", :password => "articlemetrics" }
default[:alm][:mail] = { :address => "EXAMPLE", :domain => "EXAMPLE", :user_name => "EXAMPLE", :password => "EXAMPLE" }
default[:alm][:layout] = "greenrobo"
default[:alm][:uid] = "doi"
default[:alm][:doi_prefix] = ""
default[:alm][:key] = nil
default[:alm][:secret] = nil
default[:alm][:cas_url] = nil
default[:alm][:github_client_id] = nil
default[:alm][:github_client_secret] = nil
default[:alm][:persona] = true
default[:alm][:copernicus] = { :url => "EXAMPLE", :username => "EXAMPLE", :password => "EXAMPLE" }
default[:alm][:counter] = { :url => "EXAMPLE" }
default[:alm][:crossref] = { :username => "EXAMPLE", :password => "EXAMPLE" }
default[:alm][:facebook] = { :access_token => "EXAMPLE" }
default[:alm][:mendeley] = { :api_key => "EXAMPLE" }
default[:alm][:nature] = { :api_key => "EXAMPLE" }
default[:alm][:pmc] = { :url => "EXAMPLE", :filepath => "EXAMPLE" }
default[:alm][:f1000] = { :url => "EXAMPLE", :filename => "EXAMPLE" }
default[:alm][:figshare] = { :url => "EXAMPLE" }
default[:alm][:researchblogging] = { :username => "EXAMPLE", :password => "EXAMPLE" }
default[:alm][:scopus] = { :username => "EXAMPLE", :salt => "EXAMPLE", :partner_id => "EXAMPLE" }
default[:alm][:wos] = { :url => "EXAMPLE" }
default[:alm][:seed_sample_articles] = false
default[:couch_db][:config][:httpd][:port] = 5984
