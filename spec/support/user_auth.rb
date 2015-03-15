module UserAuth
  def sign_in(role = "admin")
    user = FactoryGirl.create(:user,
                               provider: ENV["OMNIAUTH"],
                               uid: "12345",
                               name: "Joe Smith",
                               email: "joe_#{ENV["OMNIAUTH"]}@example.com",
                               role: role)
    visit "/"

    case ENV["OMNIAUTH"]
    when "cas"
      click_link "Sign in with PLOS ID"
    when "orcid"
      click_link "Sign in with ORCID"
    when "github"
      click_link "Sign in with Github"
    when "persona"
      click_on "Sign in with Persona"
    end
  end

  def sign_out
    visit "/users/sign_out"
  end
end

RSpec.configure do |config|
  config.include UserAuth, type: :feature
end
