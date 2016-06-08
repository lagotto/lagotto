module UserAuthMacros
  def sign_in(role = "admin", credentials = nil)
    if credentials == "invalid"
      OmniAuth.config.mock_auth[:jwt] = :invalid_credentials
    else
      OmniAuth.config.add_mock(:jwt, { info: { role: role }})
    end
    visit "/"

    click_link "Sign in"
  end

  def sign_out
    click_link "account_menu_link"
    click_link "sign_out"
  end
end

RSpec.configure do |config|
  config.include UserAuthMacros, type: :feature
end
