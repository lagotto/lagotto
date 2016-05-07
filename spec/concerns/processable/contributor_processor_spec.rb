require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  let!(:registration_agency) { FactoryGirl.create(:registration_agency) }
  let!(:registration_agency_datacite) { FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite") }

  describe "update_contributions" do
    it "datacite_orcids" do
      FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_datacite_orcid)
      subject.update_contributions

      expect(Contributor.count).to eq(1)
      expect(Work.count).to eq(1)

      expect(subject.contributor.pid).to eq("http://orcid.org/0000-0002-4133-2218")
      expect(subject.related_work.pid).to eq("http://doi.org/10.1594/PANGAEA.733793")
      expect(subject.error_messages).to be_nil
    end
  end

  describe "update_contributor" do
    it "update" do
      subject = FactoryGirl.create(:deposit_for_contributor)
      expect(subject.update_contributor).to be true
      expect(subject.error_messages).to be_nil

      expect(Contributor.count).to eq(1)

      contributor = Contributor.first
      expect(contributor.orcid).to eq("0000-0002-0159-2197")
      expect(contributor.credit_name).to eq("Jonathan A. Eisen")
      expect(subject.error_messages).to be_nil
    end

    it "update invalid orcid" do
      subject = FactoryGirl.create(:deposit_for_contributor, :invalid_orcid)
      expect(subject.update_contributor).to be false
      expect(subject.error_messages).to eq("contributor"=>"Validation failed: Orcid can't be blank, Orcid is invalid")

      expect(Contributor.count).to eq(0)
    end
  end
end
