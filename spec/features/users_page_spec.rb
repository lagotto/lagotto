require "rails_helper"

feature "users for admin user", type: :feature, js: true do
  before(:each) { sign_in }

  scenario "show users" do
    visit "/users"

    expect(page).to have_css ".panel-heading a", text: "Joe Smith"
    expect(page).to have_css "#api_requests"
  end
end
