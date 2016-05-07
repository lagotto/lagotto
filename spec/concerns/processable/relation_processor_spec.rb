require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  let!(:registration_agency) { FactoryGirl.create(:registration_agency) }
  let!(:registration_agency_datacite) { FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite") }

  describe "relations" do
    let!(:source) { FactoryGirl.create(:source, :datacite_related) }
    let!(:relation_type) { FactoryGirl.create(:relation_type, :has_part) }
    let!(:inv_relation_type) { FactoryGirl.create(:relation_type, :is_part_of) }

    subject = FactoryGirl.create(:deposit_for_datacite_related, :with_works)

    describe "update_relation" do
      it "should be created" do
        expect(subject.work.pid).to eq("http://doi.org/10.5061/DRYAD.47SD5")
        expect(subject.related_work.pid).to eq("http://doi.org/10.5061/DRYAD.47SD5/1")
        expect(Work.count).to eq(2)

        expect(subject.update_relation).not_to be_nil
        expect(subject.error_messages).to be_nil
      end
    end

    describe "update_inv_relation" do
      it "should be created" do
        expect(Work.count).to eq(2)

        expect(subject.update_inv_relation).not_to be_nil
        expect(subject.error_messages).to be_nil
      end
    end
  end

  describe "update_relations" do
    it "citeulike" do
      FactoryGirl.create(:source)
      FactoryGirl.create(:relation_type, :bookmarks)
      FactoryGirl.create(:relation_type, :is_bookmarked_by)
      subject.update_relations

      expect(Work.count).to eq(2)

      expect(subject.work.pid).to eq("http://www.citeulike.org/user/dbogartoit")
      expect(subject.work.relations.first.relation_type.name).to eq("bookmarks")
      expect(subject.work.relations.first.related_work).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end

    it "datacite_related" do
      FactoryGirl.create(:source, :datacite_related)
      FactoryGirl.create(:relation_type, :has_part)
      FactoryGirl.create(:relation_type, :is_part_of)
      subject = FactoryGirl.create(:deposit_for_datacite_related)
      subject.update_relations

      expect(Work.count).to eq(2)

      expect(subject.work.pid).to eq("http://doi.org/10.5061/DRYAD.47SD5")
      expect(subject.work.relations.first.relation_type.name).to eq("has_part")
      expect(subject.work.relations.first.related_work).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end

    it "datacite_github" do
      FactoryGirl.create(:source, :datacite_github)
      FactoryGirl.create(:relation_type, :is_supplement_to)
      FactoryGirl.create(:relation_type, :has_supplement)
      subject = FactoryGirl.create(:deposit_for_datacite_github)
      subject.update_relations

      expect(Work.count).to eq(2)

      expect(subject.work.pid).to eq("http://doi.org/10.5281/ZENODO.16668")
      expect(subject.work.relations.first.relation_type.name).to eq("is_supplement_to")
      expect(subject.work.relations.first.related_work).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end

    it "github" do
      FactoryGirl.create(:source, :github)
      FactoryGirl.create(:relation_type, :bookmarks)
      FactoryGirl.create(:relation_type, :is_bookmarked_by)
      subject = FactoryGirl.create(:deposit_for_github)
      subject.update_relations

      expect(Work.count).to eq(2)

      expect(subject.work.pid).to eq("https://github.com/2013/9")
      expect(subject.work.relations.first.relation_type.name).to eq("bookmarks")
      expect(subject.work.relations.first.related_work).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end

    it "facebook" do
      FactoryGirl.create(:source, :facebook)
      FactoryGirl.create(:relation_type, :references)
      FactoryGirl.create(:relation_type, :is_referenced_by)
      subject = FactoryGirl.create(:deposit_for_facebook)
      subject.update_relations

      expect(Work.count).to eq(2)

      expect(subject.work.pid).to eq("https://facebook.com/2013/9")
      expect(subject.work.relations.first.relation_type.name).to eq("references")
      expect(subject.work.relations.first.related_work).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end
  end
end
