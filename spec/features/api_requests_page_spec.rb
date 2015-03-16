require "rails_helper"

describe "api requests", type: :feature, js: true do
  before(:each) { sign_in }

  let!(:api_requests) { FactoryGirl.create_list(:api_request, 10, created_at: "2013-09-05") }

  it "show api_requests" do
    visit "/api_requests"
    expect(page).to have_css ".panel-heading", text: "September 05, 2013"
  end

  it "show time of day chart" do
    visit "/api_requests"
    expect(page).to have_css ".panel-heading", text: "Time of Day (UTC)"
  end
end
