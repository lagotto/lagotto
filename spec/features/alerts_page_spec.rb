require "rails_helper"

describe "alerts", type: :feature, js: true do
  before(:each) { sign_in }

  it "show no alerts" do
    visit "/alerts"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts"
    expect(page).to have_css "#filters"
  end

  it "show and delete alerts" do
    alert = FactoryGirl.create(:alert)

    visit "/alerts"
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    click_link "[408] The request timed out."
    expect(page).to have_css ".class-name a", text: alert.class_name

    # delete alert
    click_link "alert_#{alert.uuid}-delete"
    click_link "by Message"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts"
  end

  it "search alerts by message" do
    alert = FactoryGirl.create(:alert)

    visit "/alerts"
    fill_in "q", with: "The request timed out"
    click_button "submit"
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."

    fill_in "q", with: "no implicit conversion of nil into String"
    click_button "submit"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts with no implicit conversion of nil into String in the class name, message or PID"
  end

  it "show alerts by level" do
    alert = FactoryGirl.create(:alert)

    visit "/alerts"
    click_link "level-menu"
    click_link "Warn"
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."


    click_link "level-menu"
    click_link "Error"
    expect(page).to have_css ".alert-info", text: "There are currently no alerts"
  end

  it "show alerts by class name" do
    alert = FactoryGirl.create(:alert)

    visit "/alerts"
    click_link "alert-menu"
    click_link "Net::HTTPRequestTimeOut"
    expect(page).to have_css ".panel-heading a", text: "[408] The request timed out."


    click_link "alert-menu"
    click_link "Net::HTTPUnauthorized"
    expect(page).to have_css ".alert-info", text: "There are currently no Net::HTTPUnauthorized alerts"
  end
end
