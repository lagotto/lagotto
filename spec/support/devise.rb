RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  
  config.before(:suite) do
    OmniAuth.config.test_mode = true
    omni_hash = { :provider => "github",
                  :uid => "12345",
                  :info => { "email" => "joe@example.com", "nickname" => "joesmith" },
                  :extra => { "raw_info" => { "name" => "Joe Smith" }}}
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(omni_hash)
  end
  
  config.after(:suite) do
    OmniAuth.config.test_mode = false
  end
end