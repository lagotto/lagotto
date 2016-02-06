require "rails_helper"

describe "user sessions", :type => :feature, js: true do
  it "signs in as ORCID user" do
    sign_in
    expect(page).to have_content "Josiah Carberry"
  end

  it "sign in error as ORCID user" do
    auth = OmniAuth.config.mock_auth[:default]
    OmniAuth.config.mock_auth[:orcid] = :invalid_credentials
    visit "/"
    click_link "Sign in with ORCID"

    expect(page).to have_content "Sign in with ORCID"
    expect(page).to have_content "Error signing in with ORCID"

    OmniAuth.config.mock_auth[:default] = auth
  end

  it "signs out as user" do
    sign_in
    expect(page).to have_content "Josiah Carberry"
    sign_out
    expect(page).to have_content "Sign in with ORCID"
  end

  it "signs in as second user" do
    user = FactoryGirl.create(:user, name: "Jack White")

    sign_in
    expect(page).to have_content "Josiah Carberry"

    visit "/users"
    expect(page).to have_css ".panel-heading a.accordion-toggle", count: 2

  end
end
