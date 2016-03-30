require "rails_helper"

describe "works", type: :feature, js: true do
  before(:each) { sign_in }

  it "show no works" do
    visit "/works"

    expect(page).to have_css ".alert-info", text: "There are currently no works"
  end
end
