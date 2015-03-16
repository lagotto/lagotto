require "rails_helper"

describe "works", type: :feature, js: true do
  before(:each) { sign_in }

  it "show no works" do
    visit "/works"

    expect(page).to have_css ".alert-info", text: "There are currently no works"
    expect(page).to have_css "#new-work"
  end

  context "add work" do
    let(:title) { "Derivation of Hair-Inducing Cell from Human Pluripotent Stem Cells" }
    let(:doi) { "10.1371/journal.pone.0116892" }
    let!(:work_type) { FactoryGirl.create(:work_type) }

    it "new work" do
      visit "/works"
      click_link "new-work"

      expect(page).to have_css ".panel-heading", text: "New Work"
    end

    it "create work" do
      visit "/works"
      click_link "new-work"

      fill_in "work_title", with: title
      fill_in "work_doi", with: doi
      click_button "Save"

      expect(page).to have_css "h4.work a", text: title
    end

    it "create work with incomplete date" do
      visit "/works"
      click_link "new-work"

      fill_in "work_title", with: title
      fill_in "work_doi", with: doi
      select "", from: "work_day"
      select "", from: "work_month"
      select "2013", from: "work_year"
      click_button "Save"

      expect(page).to have_css ".date", text: "2013."
    end

    it "create dataset" do
      work_type = FactoryGirl.create(:work_type, name: "dataset")
      visit "/works"
      click_link "new-work"

      fill_in "work_title", with: title
      fill_in "work_doi", with: doi
      select "dataset", from: "work_work_type_id"
      click_button "Save"

      expect(page).to have_css "h4.work a", text: "a"
    end

    it "missing title error" do
      visit "/works"
      click_link "new-work"

      fill_in "work_doi", with: doi
      click_button "Save"

      expect(page).to have_css ".work_title .has-error", text: "can't be blank"
    end

    it "missing doi error" do
      visit "/works"
      click_link "new-work"

      fill_in "work_title", with: title
      click_button "Save"

      expect(page).to have_css ".work_doi .has-error", text: "must provide at least one persistent identifier"
    end

    it "date in future error" do
      visit "/works"
      click_link "new-work"

      fill_in "work_title", with: title
      fill_in "work_doi", with: doi
      select "December", from: "work_month"
      click_button "Save"

      expect(page).to have_css ".work_published_on .has-error", text: "is a date in the future"
    end
  end
end
