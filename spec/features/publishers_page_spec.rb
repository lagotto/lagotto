require "rails_helper"

describe "publishers", type: :feature, vcr: true, js: true do
  before(:each) do
    sign_in
    Publisher.delete_all
  end

  it "show no publishers" do
    visit "/publishers"

    expect(page).to have_css ".alert-info", text: "There are currently no publishers"
    expect(page).to have_css "#new-publisher"
  end

  it "show publishers" do
    publisher = FactoryGirl.create(:publisher)
    visit "/publishers"

    expect(page).to have_css "h4.work a", text: "Public Library of Science (PLoS)"
    expect(page).to have_css "#new-publisher"
  end
end
