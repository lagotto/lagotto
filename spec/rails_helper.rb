require 'simplecov'
SimpleCov.start do
  coverage_dir 'artifacts/coverage'
end

# set ENV variables for testing
ENV["RAILS_ENV"] = "test"
ENV["OMNIAUTH"] = "cas"
ENV["CAS_URL"] = "https://register.example.org"
ENV["CAS_INFO_URL"] = "http://example.org/users"
ENV["CAS_PREFIX"]= "/cas"
ENV["API_KEY"] = "12345"
ENV["ADMIN_EMAIL"] = "info@example.org"
ENV["IMPORT"] = "member"

# set up Code Climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda-matchers"
require "email_spec"
require "factory_girl_rails"
require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"
require "capybara-screenshot/rspec"
require "database_cleaner"
require "webmock/rspec"
require "rack/test"
require "draper/test/rspec_integration"
require "devise"
require "sidekiq/testing"
require "colorize"

# include required concerns
include Networkable
include Couchable

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    timeout: 180,
    inspector: true,
    debug: false,
    window_size: [1024, 768]
  })
end

Capybara.javascript_driver = :poltergeist
Capybara.default_selector = :css

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

WebMock.disable_net_connect!(
  allow: ['codeclimate.com', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.filter_sensitive_data("<API_KEY>") { ENV["API_KEY"] }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # config.expect_with :rspec do |expectations|
  #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  # end

  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end

  OmniAuth.config.test_mode = true
  config.before(:each) do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      provider: ENV["OMNIAUTH"],
      uid: "12345",
      info: { "email" => "joe_#{ENV["OMNIAUTH"]}@example.com",
              "name" => "Joe Smith" },
      extra: { "email" => "joe_#{ENV["OMNIAUTH"]}@example.com",
               "name" => "Joe Smith" }
    })
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = :random

  # config.include WebMock::API
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include MailerMacros

  config.include FactoryGirl::Syntax::Methods

  config.include Rack::Test::Methods, :type => :api

  config.include Devise::TestHelpers, :type => :controller
  config.include Rack::Test::Methods, :type => :controller

  def app
    Rails.application
  end

  # restore application-specific ENV variables after each example
  config.after(:each) do
    ENV_VARS.each { |k,v| ENV[k] = v }
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # FactoryGirl.lint
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :feature) do
    unless Heartbeat.memcached_up?
      raise <<-EOS.gsub(/^\s*\|/, '').colorize(:red)
        |Memcached doesn't appear to be running! You will need it running in
        |order to successfully run feature specs.
        |
        |Looking for it on:
        |  MEMCACHE_SERVERS: #{ENV["MEMCACHE_SERVERS"].inspect}
        |  HOSTNAME: #{ENV["HOSTNAME"].inspect}
        |  PORT: 11211
        |
        |Output of ps aux | grep memcache:
        |  #{`ps aux | grep memcache`}
        |
        |Output of lsof -i :11211:
        |  #{`lsof -i :11211`}
      EOS
    end
  end

  # Configure caching, use ":caching => true" when you need to test this
  config.around(:each) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  config.before(:each) do |example|
    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all

    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :feature
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end

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
