source 'http://rubygems.org'

gem 'rails', '3.2.7'
gem 'mysql2', '0.3.11'

gem "delayed_job", "~> 3.0.3"
gem 'delayed_job_active_record', '0.3.2'
gem 'daemons', '1.1.8'

gem "libxml-ruby", "~> 2.3.3", :require => 'xml'
gem 'mumboe-soap4r', '1.5.8.5'
gem "koala", "~> 1.5.0"
gem 'will_paginate', '3.0.3'
gem "devise", "~> 2.1.2"
gem 'validates_timeliness', '~> 3.0.2'

group :assets do
  gem 'uglifier', '1.2.7'
  gem 'jquery-rails', '2.0.2'
  gem 'therubyracer', '0.10.1', :require => "v8"
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem "cucumber-rails", "~> 1.3.0"
  gem "capybara", ">= 1.1.2"
  gem "database_cleaner", "~> 0.8.0"
  gem "launchy", "~> 2.1.2"
  gem "email_spec", "~> 1.2.1"
  gem "rack-test", "~> 0.6.1"
  gem "simplecov", "~> 0.6.4", :require => false
  gem "shoulda-matchers", "~> 1.2.0", :require => false
end

group :test, :development do
  gem "rspec-rails", "~> 2.11.0"
end
