require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_id) }

  describe "update_work" do
    let!(:relation_type) { FactoryGirl.create(:relation_type, :bookmarks) }

    it "citeulike" do
      expect(subject.update_work).to eq("http://www.citeulike.org/user/dbogartoit")

      # expect(Work.count).to eq(2)
      # work = Work.last
      # expect(work.title).to eq("Audiotactile interactions in temporal perception")
      # expect(work.pid).to eq("http://doi.org/10.3758/s13423-011-0070-4")

      # expect(work.relations.length).to eq(1)
      # relation = Relation.first
      # expect(relation.relation_type.name).to eq("cites")
      # expect(relation.source.name).to eq("crossref")
      # expect(relation.related_work).to eq(related_work)
    end

    it "datacite_related" do
      subject = FactoryGirl.create(:deposit, :datacite_related)
      expect(subject.update_work).to eq("http://doi.org/10.5061/DRYAD.47SD5")
    end

    it "datacite_github" do
      subject = FactoryGirl.create(:deposit, :datacite_github)
      expect(subject.update_work).to eq("http://doi.org/10.5281/ZENODO.16668")
    end
  end
end
