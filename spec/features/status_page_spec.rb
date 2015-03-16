require "rails_helper"

describe "status", type: :feature, js: true do
  it "show works status" do
    visit "/status"

    expect(page).to have_css "#chart_works"
  end

  it "show events status" do
    visit "/status"

    expect(page).to have_css "#chart_events"
  end

  it "show sources status" do
    visit "/status"

    expect(page).to have_css "#chart_sources"
  end

  it "show API responses status" do
    visit "/status"

    expect(page).to have_css "#chart_responses"
  end

  it "show API requests status" do
    visit "/status"

    expect(page).to have_css "#chart_requests"
  end

  it "show API requests average status" do
    visit "/status"

    expect(page).to have_css "#chart_average"
  end
end

describe "status for admin user", type: :feature, js: true do
  before(:each) { sign_in }

  it "show alerts status" do
    visit "/status"

    expect(page).to have_css "#chart_alerts"
  end

  it "show db_size status" do
    visit "/status"

    expect(page).to have_css "#chart_db_size"
  end

  it "show version status" do
    visit "/status"

    expect(page).to have_css "#version"
  end

  it "show version status" do
    visit "/status"

    expect(page).to have_css ".panel-heading", text: "Jobs"
  end
end
