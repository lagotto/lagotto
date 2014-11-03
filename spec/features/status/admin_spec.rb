require "rails_helper"

feature "status page", :javascript => true do
  before(:context) do
    FactoryGirl.create(:admin_user)
  end

  before(:each) do
    date = Date.today - 1.day
    FactoryGirl.create_list(:article_with_events, 5, year: date.year, month: date.month, day: date.day)
    FactoryGirl.create_list(:alert, 2)
    FactoryGirl.create(:delayed_job)
    FactoryGirl.create_list(:api_request, 4)
    FactoryGirl.create_list(:api_response, 6)
    body = File.read(fixture_path + 'releases.json')
    stub_request(:get, "https://api.github.com/repos/articlemetrics/lagotto/releases").to_return(body: body)
    3.times do |i|
      put_lagotto_data("#{ENV['COUCHDB_URL']}/#{i}", data: { "name" => "Fred" })
    end

    login_with_oauth(:persona)
  end

  scenario "should see that we have 5 articles" do
    visit "/status"

    expect(page).to have_css "#articles_count", :text => 5
  end

  scenario "should see that we have 5 recent articles" do
    visit "/status"

    expect(page).to have_css "#articles_last30_count", :text => 5
  end

  scenario "should see that we have 250 events" do
    visit "/status"

    expect(page).to have_css "#events_count", :text => 250
  end

  scenario "should see that we have 6 API responses" do
    visit "/status"

    expect(page).to have_css "#responses_count", :text => 6
  end

  scenario "should see that we have 4 API requests" do
    visit "/status"

    expect(page).to have_css "#requests_count", :text => 4
  end

  scenario "should see that we have 1 user" do
    visit "/status"

    expect(page).to have_css "#users_count", :text => 1
  end

  scenario "should see that the CouchDB size is 5.45 kB" do
    visit "/status"

    expect(page).to have_css "#couchdb_size", :text => "5.45 kB"
  end

  scenario "should see that we have no disables source" do
    visit "/status"

    expect(page).to have_no_css "#sources_disabled_count"
  end
end
