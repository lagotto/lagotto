source 'http://rubygems.org'
ruby '2.6.5'

gem 'dotenv-rails', groups: [:development, :test]
gem 'rails', '~> 5.0.0'
gem 'mysql2'
gem 'sidekiq'
gem 'sinatra'
gem 'rake'
gem "whenever", require: false
gem 'parse-cron'
gem "mail"
gem 'nondestructive_migrations'
gem 'immigrant'
gem "state_machine", "~> 1.2.0", :git => 'https://github.com/fly1tkg/state_machine.git', :branch => 'issue/334'
gem "logstash-logger"
gem 'bugsnag'
gem 'sentry-raven'

gem "faraday"
gem "faraday_middleware"
gem 'excon'
gem 'addressable'
gem 'postrank-uri'
gem "multi_xml"
gem "nokogiri"
gem "multi_json"
gem "oj"
gem 'safe_yaml'
gem 'hashie'
gem 'rubyzip', require: 'zip'

gem "devise"
gem "omniauth-persona"
gem "omniauth-cas"
gem 'omniauth-github'
gem "omniauth-orcid"
gem 'omniauth'
gem 'cancancan'
gem "validates_timeliness"
gem "strip_attributes"
gem 'draper'
gem 'jbuilder'
gem "swagger-docs"
gem 'swagger-ui_rails'
gem "dalli"
gem 'will_paginate'
gem "will_paginate-bootstrap"
gem "simple_form"
gem 'nilify_blanks'
gem "github-markdown"
gem "rouge"
gem 'dotiw'

gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'sass-rails', '5.0.7' # breaking change in 6.0
gem "uglifier"
gem 'coffee-rails'
gem "ember-cli-rails"

gem "zenodo"
gem 'tzinfo-data'

group :development do
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-npm'
  # gem 'spring'
  gem 'hologram'
end

group :test do
  gem "factory_girl_rails", require: false
  gem "capybara"
  gem 'capybara-screenshot'
  gem 'colorize'
  gem "database_cleaner", '1.6.2' # before they added safeguards
  gem "launchy"
  gem "email_spec"
  gem "rack-test", require: 'rack/test'
  gem "simplecov", require: false
  gem 'codeclimate-test-reporter', require: false
  gem "shoulda-matchers", require: false
  gem "webmock"
  gem 'vcr'
  gem "poltergeist"
  gem "with_env"
  gem "rspec_junit_formatter"
end

group :test, :development do
  gem 'byebug'
  gem "rspec-rails"
  # gem 'spring-commands-rspec'
  gem 'teaspoon-jasmine'
  gem "brakeman", require: false
  gem 'rubocop'
  gem 'bullet'
end

gem 'rack-mini-profiler', require: false
gem 'puma'
