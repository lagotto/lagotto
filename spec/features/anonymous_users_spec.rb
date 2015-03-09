require "rails_helper"

describe "no access for anonymous user", type: :feature, js: true do
  it "don't show users" do
    visit "/users"

    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "don't show API requests" do
    visit "/api_requests"

    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "don't show alerts" do
    visit "/alerts"

    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "don't show filters" do
    visit "/filters"

    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "don't show user profile" do
    visit "/users/me"

    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end
end

describe "no button for anonymous user", type: :feature, js: true do
  it "don't show add work button" do
    visit "/works"

    expect(page).to_not have_css "#new-work"
  end

  it "don't show add publisher button" do
    visit "/publishers"

    expect(page).to_not have_css "#new-publisher"
  end

  it "don't show source installation button" do
    visit "/sources"

    expect(page).to_not have_css "#installation-pill"
  end
end
