module UserAuthMacros
  def sign_in(role = "admin")
    OmniAuth.config.add_mock(:jwt, { info: { role: role }})
    visit "/"

    click_link "Sign in"
  end

  def sign_out
    visit "/sign_out"
  end
end

RSpec.configure do |config|
  config.include UserAuthMacros, type: :feature
end
