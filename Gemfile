source 'https://rubygems.org'

gem 'rails', '~> 4.2', '>= 4.2.6'
gem 'mysql2', '0.3.18'

gem "dotenv", '~> 2.1', '>= 2.1.1'
gem 'sidekiq', '~> 4.0', '>= 4.0.1'
gem 'rake', '~> 10.4.2'
gem 'parse-cron', '~> 0.1.4'
gem 'mailgun-ruby', '~> 1.1'
gem 'slack-notifier', '~> 1.5', '>= 1.5.1'
gem 'backport_new_renderer', '~> 1.0'
gem 'immigrant', '~> 0.3.4'
gem "state_machine", "~> 1.2.0", :git => 'https://github.com/fly1tkg/state_machine.git', :branch => 'issue/334'
gem 'lograge', '~> 0.3.5'
gem 'httplog'
gem 'bugsnag', '~> 2.8.6'

gem 'maremma', '~> 3.1', '>= 3.1.2'
gem 'postrank-uri', '~> 1.0.18'
gem "multi_xml", "~> 0.5.5"
gem "nokogiri", "~> 1.6.0"
gem 'cirneco', '~> 0.9.9'
gem 'config', '~> 1.0.0'
gem 'sprig', '~> 0.1.7'
gem 'hashie', '~> 3.3.2'
gem 'namae', '~> 0.10.1'
gem 'gender_detector', '~> 0.1.2'
gem 'rubyzip',  "~> 1.1", :require => 'zip'
gem 'colorize', '~> 0.7.7'

gem 'jwt', '~> 1.5', '>= 1.5.4'
gem 'cancancan', '~> 1.9.2'
gem "validates_timeliness", "~> 3.0.14"
gem 'iso8601', '~> 0.9.0'
gem "strip_attributes", "~> 1.2"
gem 'active_model_serializers', '~> 0.10.4'
gem "dalli", "~> 2.7.0"
gem 'will_paginate', '3.0.7'
gem "will_paginate-bootstrap", "~> 1.0.1"
gem 'nilify_blanks', '~> 1.2.0'
gem "github-markdown", "~> 0.6.3"
gem "rouge", "~> 1.7.2"
gem 'dotiw', '~> 2.0'

group :development do
  gem 'pry-rails', '~> 0.3.2'
  gem 'better_errors', '~> 2.0.0'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'spring', '~> 1.6', '>= 1.6.3'
end

group :test do
  gem "factory_girl_rails", "~> 4.5.0", :require => false
  gem "capybara", "~> 2.4.4"
  gem "database_cleaner", "~> 1.3.0"
  gem "launchy", "~> 2.4.2"
  gem "rack-test", "~> 0.6.2", :require => "rack/test"
  gem "simplecov", "~> 0.9.1", :require => false
  gem 'codeclimate-test-reporter', '~> 0.4.1', :require => nil
  gem "shoulda-matchers", "~> 2.7.0", :require => false
  gem "webmock", "~> 1.20.0"
  gem 'vcr', '~> 2.9.3'
  gem "with_env", "~> 1.1.0"
  gem 'test_after_commit', '~> 0.4.2'
end

group :test, :development do
  gem "rspec-rails", "~> 3.1.0"
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem "brakeman", "~> 2.6.0", :require => false
  gem 'rubocop', '~> 0.27.0'
  gem 'bullet', '~> 4.14.0'
end
