require "rails_helper"

describe "docs", type: :feature do
  it "show installation", js: true do
    visit "/docs/installation"

    expect(page).to have_css ".panel-heading a", text: "Introduction"
  end

  it "show deployment", js: true do
    visit "/docs/deployment"

    expect(page).to have_css ".panel-heading", text: "Deployment"
  end

  it "show setup", js: true do
    visit "/docs/setup"

    expect(page).to have_css ".panel-heading a", text: "Adding Users"
  end

  it "show sources", js: true do
    visit "/docs/sources"

    expect(page).to have_css ".panel-heading", text: "Sources"
  end

  it "show API", js: true do
    visit "/docs/api"

    expect(page).to have_css ".panel-heading a", text: "Basic Information"
  end

  it "show rake", js: true do
    visit "/docs/rake"

    expect(page).to have_css ".panel-heading a", text: "Introduction"
  end

  it "show alerts", js: true do
    visit "/docs/alerts"

    expect(page).to have_css ".panel-heading a", text: "Setup"
  end

  it "show styleguide", js: true do
    visit "/docs/styleguide"

    expect(page).to have_css ".panel-heading a", text: "Colors"
  end

  it "show releases", js: true do
    visit "/docs/releases"

    expect(page).to have_css ".panel-heading a", text: "ALM 2.0"
  end

  it "show roadmap", js: true do
    visit "/docs/roadmap"

    expect(page).to have_css ".panel-heading a", text: "4.0 Data-Push Model"
  end

  it "show contributors", js: true do
    visit "/docs/contributors"

    expect(page).to have_css ".panel-heading", text: "Contributors"
  end
end
