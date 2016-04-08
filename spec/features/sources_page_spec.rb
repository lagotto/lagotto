require "rails_helper"

describe "sources", type: :feature, js: true do
  let!(:source) { FactoryGirl.create(:source) }
  let!(:work) { FactoryGirl.create(:work, :with_events) }

  it "show summary" do
    visit "/sources"

    expect(page).to have_css "td a", text: "CiteULike"
  end

  it "show works" do
    visit "/sources"
    click_link "Results"

    expect(page).to have_css ".panel-heading", text: "Works with results"
  end

  it "show results" do
    visit "/sources"
    click_link "Results"

    expect(page).to have_css ".panel-heading", text: "Total number of results"
  end
end
