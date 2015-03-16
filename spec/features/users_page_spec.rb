require "rails_helper"

describe "users for admin user", type: :feature, js: true do
  before(:each) { sign_in }

  it "show users" do
    visit "/users"

    expect(page).to have_css ".panel-heading a", text: "Joe Smith"
    expect(page).to have_css "#api_requests"
  end

  it "show user profile" do
    visit "/users/me"
    expect(page).to have_css ".panel-heading", text: /Your Account/
  end
end
