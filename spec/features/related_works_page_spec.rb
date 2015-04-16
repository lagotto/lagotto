require "rails_helper"

describe "related_works", type: :feature, js: true do
  let!(:work) { FactoryGirl.create(:work_with_events) }

  it "show related_works" do
    visit "/related_works"

    expect(page).to have_css "h1#api_key", text: "Related Works"
  end
end
