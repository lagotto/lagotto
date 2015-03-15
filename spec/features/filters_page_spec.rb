require "rails_helper"

describe "filters", type: :feature, js: true do
  before(:each) { sign_in }

  it "show filters" do
    visit "/filters"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts"
  end
end
