require "rails_helper"

describe "notifications", type: :feature, js: true do
  before(:each) { sign_in }

  it "show no notifications" do
    visit "/notifications"
    expect(page).to have_css ".alert-info", text: "There are currently no notifications"
  end

  it "show and delete notifications" do
    notification = FactoryGirl.create(:notification)

    visit "/notifications"
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    click_link "[408] The request timed out."
    expect(page).to have_css ".class-name a", text: notification.class_name

    # delete notification
    click_link "notification_#{notification.uuid}-delete"
    click_link "notification_#{notification.uuid}-delete-message"
    expect(page).to have_css ".alert-info", text: "There are currently no notifications"
  end

  it "search notifications by message" do
    notification = FactoryGirl.create(:notification)

    visit "/notifications"
    within('.form-horizontal') do
      fill_in "q", with: "The request timed out"
      click_button "submit"
    end
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    within('.form-horizontal') do
      fill_in "q", with: "no implicit conversion of nil into String"
      click_button "submit"
    end
    expect(page).to have_css ".alert-info", text: "There are currently no notifications with no implicit conversion of nil into String in the class name, message or PID"
  end

  it "show notifications by level" do
    notification = FactoryGirl.create(:notification)

    visit "/notifications"
    within('.col-md-3') do
      click_link "Warn"
    end
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    click_link "Error"
    expect(page).to have_css ".alert-info", text: "There are currently no notifications"
  end

  it "show notifications by class name" do
    notification = FactoryGirl.create(:notification)

    visit "/notifications"
    within('.col-md-3') do
      click_link "Net::HTTPRequestTimeOut"
    end
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    click_link "Net::HTTPUnauthorized"
    expect(page).to have_css ".alert-info", text: "There are currently no Net::HTTPUnauthorized notifications"
  end
end
