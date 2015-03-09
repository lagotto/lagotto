require "rails_helper"

feature "status", type: :feature, js: true do
  scenario "show works status" do
    visit "/status"

    expect(page).to have_css "#chart_works"
  end

  scenario "show events status" do
    visit "/status"

    expect(page).to have_css "#chart_events"
  end

  scenario "show sources status" do
    visit "/status"

    expect(page).to have_css "#chart_sources"
  end

  scenario "show API responses status" do
    visit "/status"

    expect(page).to have_css "#chart_responses"
  end

  scenario "show API requests status" do
    visit "/status"

    expect(page).to have_css "#chart_requests"
  end

  scenario "show API requests average status" do
    visit "/status"

    expect(page).to have_css "#chart_average"
  end
end

feature "status for admin user", type: :feature, js: true do
  before(:each) { sign_in }

  scenario "show alerts status" do
    visit "/status"

    expect(page).to have_css "#chart_alerts"
  end

  scenario "show db_size status" do
    visit "/status"

    expect(page).to have_css "#chart_db_size"
  end

  scenario "show version status" do
    visit "/status"

    expect(page).to have_css "#version"
  end

  scenario "show version status" do
    visit "/status"

    expect(page).to have_css ".panel-heading", text: "Jobs"
  end
end
