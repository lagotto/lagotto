ENV["RAILS_ENV"] = 'test'
require 'simplecov'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'email_spec'
require 'shoulda-matchers'
require 'factory_girl_rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'webmock/rspec'

include WebMock::API
WebMock.disable_net_connect!(:allow_localhost => true)

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  
  config.include FactoryGirl::Syntax::Methods
  
  config.use_transactional_fixtures = false
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
  
  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end