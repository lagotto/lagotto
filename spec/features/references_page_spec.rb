require "rails_helper"

describe "references", type: :feature, js: true do
  let!(:work) { FactoryGirl.create(:work_with_events) }

  it "show references" do
    visit "/references"

    expect(page).to have_css "h1#api_key", text: "References"
  end
end
