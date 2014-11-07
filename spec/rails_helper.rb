# set ENV variables for testing
ENV["RAILS_ENV"] = "test"
ENV["API_KEY"] = "12345"
ENV["ADMIN_EMAIL"] = "info@example.org"
ENV["WORKERS"] = "1"
ENV["COUCHDB_URL"] = "http://localhost:5984/alm_test"
ENV["IMPORT"] = "member"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'email_spec'
require 'factory_girl_rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'database_cleaner'
require 'webmock/rspec'
require "rack/test"
require 'draper/test/rspec_integration'
require 'devise'

# include required concerns
include Networkable
include Couchable

include WebMock::API
allowed_hosts = [/codeclimate.com/, ENV['HOSTNAME']]
WebMock.disable_net_connect!(allow: allowed_hosts, allow_localhost: true)

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :timeout => 60,
                                         :js_errors => true,
                                         :debug => false,
                                         :inspector => true)
end
Capybara.javascript_driver = :poltergeist

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include MailerMacros

  config.include FactoryGirl::Syntax::Methods

  config.include Rack::Test::Methods, :type => :api


  config.include Devise::TestHelpers, :type => :controller
  config.include Rack::Test::Methods, :type => :controller

  config.include IntegrationSpecHelper, :type => :feature

  def app
    Rails.application
  end

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    reset_email
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Configure caching, use ":caching => true" when you need to test this
  config.around(:each) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  OmniAuth.config.test_mode = true
  omni_hash = { :provider => "persona",
                :uid => "12345",
                :info => { "email" => "joe@example.com",
                           "username" => "joe@example.com" }}
  OmniAuth.config.mock_auth[:persona] = OmniAuth::AuthHash.new(omni_hash)

# Before('@couchdb') do
#   put_lagotto_database
# end

# After('@couchdb') do
#   delete_lagotto_database
# end

# Before('@delayed') do
#   Delayed::Worker.delay_jobs = true
#   system "RAILS_ENV=test script/delayed_job -n 2 start"
# end

# After('@delayed') do
#   Delayed::Worker.delay_jobs = false
#   system "RAILS_ENV=test script/delayed_job stop"
# end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end
end
