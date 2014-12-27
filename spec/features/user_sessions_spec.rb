require "rails_helper"

describe "user sessions", :type => :feature do
  it "signs in as CAS user", js: true do
    sign_in
    expect(page).to have_content "joe@example.com"
  end

  it "sign in error as CAS user", js: true do
    auth = OmniAuth.config.mock_auth[:default]
    OmniAuth.config.mock_auth[:default] = :invalid_credentials

    sign_in
    expect(page).to have_content "Sign in with PLOS ID"
    expect(page).to have_content "Could not authorize you from CAS because \"Invalid credentials\""

    OmniAuth.config.mock_auth[:default] = auth
  end

  it "signs in as Persona user", js: true do
    ENV["OMNIAUTH"] = "persona"
    sign_in
    expect(page).to have_content "joe@example.com"
  end

  it "signs in as ORCID user", js: true do
    ENV["OMNIAUTH"] = "orcid"
    sign_in
    expect(page).to have_content "joe@example.com"
  end

  it "signs in as Github user", js: true do
    ENV["OMNIAUTH"] = "github"
    sign_in
    expect(page).to have_content "joe@example.com"
  end

  it "signs out as user", js: true do
    sign_in
    expect(page).to have_content "joe@example.com"
    sign_out("joe@example.com")
    expect(page).to have_content "Sign in with PLOS ID"
  end
end
