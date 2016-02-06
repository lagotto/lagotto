require "rails_helper"

describe "access for staff user", type: :feature, js: true do
  before(:each) { sign_in("staff") }

  it "show users" do
    visit "/users"
    expect(page).to have_css ".panel-heading a", text: "Josiah Carberry"
  end

  it "show api_requests" do
    visit "/api_requests"
    expect(page).to have_css "h1", "API Requests"
  end

  it "show notifications" do
    visit "/notifications"
    expect(page).to have_css ".alert-info", text: "There are currently no notifications"
  end

  it "show filters" do
    visit "/filters"
    expect(page).to have_css ".alert-info", text: "There are currently no filters"
  end

  it "show user profile" do
    visit "/users/me"
    expect(page).to have_css ".panel-heading", text: /Your Account/
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

  it "don't show source action button" do
    source = FactoryGirl.create(:source)
    visit "/sources"
    click_link "Events"
    expect(page).to_not have_css ".status", text: "Actions"
  end

  it "don't show notification delete button" do
    notification = FactoryGirl.create(:notification)
    visit "/notifications"
    click_link "[408] The request timed out."
    expect(page).to_not have_css "#notification_#{notification.id}-delete"
  end
end
