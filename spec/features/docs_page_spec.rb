require "rails_helper"

describe "docs", type: :feature, js: true do
  it "show homepage" do
    visit "/"

    expect(page).to have_css "h2", text: "Article-Level Metrics"
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

  it "show sources" do
    visit "/docs/sources"

    expect(page).to have_css ".panel-heading", text: "Sources"
  end

  it "show API" do
    visit "/docs/api"

    expect(page).to have_css ".panel-heading a", text: "Basic Information"
  end

  it "show rake" do
    visit "/docs/rake"

    expect(page).to have_css ".panel-heading a", text: "Introduction"
  end

  it "show alerts" do
    visit "/docs/alerts"

    expect(page).to have_css ".panel-heading a", text: "Setup"
  end

  it "show styleguide" do
    visit "/docs/styleguide"

    expect(page).to have_css ".panel-heading a", text: "Colors"
  end

  it "show releases" do
    visit "/docs/releases"

    expect(page).to have_css ".panel-heading a", text: "ALM 2.0"
  end

  it "show roadmap" do
    visit "/docs/roadmap"
    expect(page).to have_css ".panel-heading a", text: /\d+\.\d+ Data-Push Model/
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
