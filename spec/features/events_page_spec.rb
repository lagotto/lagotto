require "rails_helper"

describe "events", type: :feature, js: true do
  let!(:work) { FactoryGirl.create(:work_with_events) }

  it "show events" do
    visit "/events"

    expect(page).to have_css "h4.work a"
  end
end
