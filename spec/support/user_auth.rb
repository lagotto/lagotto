module UserAuth
  def sign_in
    visit "/"

    case ENV["OMNIAUTH"]
    when "cas"
      click_link "Sign in with PLOS ID"
    when "orcid"
      click_link "Sign in with ORCID"
    when "github"
      click_link "Sign in with Github"
    else
      click_button "Sign in with Persona"
    end
  end

  def sign_out(account_name)
    visit "/"
    click_link account_name
    click_link "Sign Out"
  end
end

RSpec.configure do |config|
  config.include UserAuth, type: :feature
end
