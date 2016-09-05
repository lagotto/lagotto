require "rails_helper"

describe "docs", type: :feature, js: true do
  it "show homepage" do
    visit "/"

    expect(page).to have_css "h2", text: "DataCite Event Data"
  end

  it "show installation" do
    visit "/docs/installation"

    expect(page).to have_css ".panel-heading a", text: "Introduction"
  end

  it "show deployment" do
    visit "/docs/deployment"

    expect(page).to have_css ".panel-heading", text: "Deployment"
  end

  it "show setup" do
    visit "/docs/setup"

    expect(page).to have_css ".panel-heading a", text: "Adding Users"
  end

  it "show agents" do
    visit "/docs/agents"

    expect(page).to have_css ".panel-heading", text: "Agents"
  end

  it "show API" do
    visit "/docs/api"

    expect(page).to have_css ".panel-heading a", text: "Basic Information"
  end

  it "show rake" do
    visit "/docs/rake"

    expect(page).to have_css ".panel-heading a", text: "Introduction"
  end

  it "show notifications" do
    visit "/docs/notifications"

    expect(page).to have_css ".panel-heading a", text: "Setup"
  end

  it "show releases" do
    visit "/docs/releases"

    expect(page).to have_css ".panel-heading a", text: "ALM 2.0"
  end

  it "show roadmap" do
    visit "/docs/roadmap"
    expect(page).to have_css ".panel-heading a", text: /\d+\.\d+ Bug fixes May 2016/
  end

  it "show contributors" do
    visit "/docs/contributors"

    expect(page).to have_css ".panel-heading", text: "Contributors"
  end

  it "show alert for missing page" do
    visit "/docs/xxx"

    expect(page).to have_css ".alert-info", text: "No documentation for xxx found"
  end
end
