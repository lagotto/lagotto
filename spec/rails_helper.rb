# set ENV variables for testing
ENV["RAILS_ENV"] = "test"
ENV["API_KEY"] = "12345"
ENV["ADMIN_EMAIL"] = "info@example.org"
ENV["IMPORT"] = "member"
ENV["ZENODO_KEY"] = "123"
ENV["ZENODO_URL"] = "https://sandbox.zenodo.org/api/"

# set up Code Climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda-matchers"
require "factory_girl_rails"
require "capybara/rspec"
require "capybara/rails"
require "database_cleaner"
require "webmock/rspec"
require "rack/test"
require "maremma"
require "sidekiq/testing"
require "colorize"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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
  c.filter_sensitive_data("<SLACK_WEBHOOK_URL>") { ENV["SLACK_WEBHOOK_URL"] }
  c.filter_sensitive_data("<MAILGUN_API_KEY>") { ENV["MAILGUN_API_KEY"] }
  c.filter_sensitive_data("<MAILGUN_DOMAIN>") { ENV["MAILGUN_DOMAIN"] }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # config.expect_with :rspec do |expectations|
  #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  # end

  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end

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
  config.include MailerMacros
  config.include FactoryGirl::Syntax::Methods
  config.include Rack::Test::Methods, :type => :api
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

  # Configure caching, use ":caching => true" when you need to test this
  config.around(:each) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  # only run vcr for metadata key :vcr, use webmock otherwise
  config.around(:each) do |ex|
    if ex.metadata.key?(:vcr)
      ex.run
    else
      VCR.turned_off { ex.run }
    end
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
