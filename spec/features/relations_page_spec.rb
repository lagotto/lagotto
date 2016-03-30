require "rails_helper"

describe "relations", type: :feature, js: true do
  let!(:work) { FactoryGirl.create(:work, :with_events) }

  it "show relations" do
    visit "/relations"

    expect(page).to have_css "h1#api_key", text: "Relations"
  end
end
