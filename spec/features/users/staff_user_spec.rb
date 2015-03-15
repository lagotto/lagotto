require "rails_helper"

describe "access for staff user", type: :feature, js: true do
  before(:each) { sign_in("staff") }

  it "show users" do
    visit "/users"
    expect(page).to have_css ".panel-heading a", text: "Joe Smith"
  end

  it "show API requests" do
    visit "/api_requests"
    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "show alerts" do
    visit "/alerts"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts"
  end

  it "show filters" do
    visit "/filters"
    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end

  it "show user profile" do
    visit "/users/me"
    expect(page).to have_css ".alert-warning", text: "404 The page you are looking for doesn't exist."
  end
end

describe "no button for staff user", type: :feature, js: true do
  before(:each) { sign_in("staff") }

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
