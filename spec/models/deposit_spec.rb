require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_id) }

  describe "update_work" do
    it "should be created" do
      expect(subject.update_work).not_to be_nil
      expect(subject.error_messages).to be_nil
      expect(subject.work.pid).to eq("http://www.citeulike.org/user/dbogartoit")
    end
  end

  describe "update_related_work" do
    it "should be created" do
      expect(subject.update_related_work).not_to be_nil
      expect(subject.error_messages).to be_nil
      expect(subject.related_work.pid).to eq("http://doi.org/10.1371/JOURNAL.PMED.0030186")
    end
  end

  describe "relations" do
    let!(:source) { FactoryGirl.create(:source, :datacite_related) }
    let!(:relation_type) { FactoryGirl.create(:relation_type, :has_part) }
    let!(:inv_relation_type) { FactoryGirl.create(:relation_type, :is_part_of) }

    subject = FactoryGirl.create(:deposit_for_datacite_related, :with_works)

    describe "update_relation" do
      it "should be created" do
        # expect(subject.work.valid?).to eq("http://doi.org/10.5061/DRYAD.47SD5")
        # expect(subject.related_work.errors).to eq("http://doi.org/10.5061/DRYAD.47SD5/1")
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
      #expect(subject.work.related_works.first).to eq(subject.related_work)
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
      #expect(subject.work.related_works.first).to eq(subject.related_work)
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
      #expect(subject.work.related_works.first).to eq(subject.related_work)
    end
  end

  describe "update_publisher" do
    it "update" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      publisher = subject.update_publisher
      expect(publisher.name).to eq("ANDS.CENTRE-1")
      expect(publisher.title).to eq("Griffith University")
    end

    it "update missing title" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      expect(subject.update_publisher).to be_nil
      expect(subject.human_state_name).to eq("waiting")
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")
    end
  end

  describe "process_data" do
    it "publisher" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "publisher failed" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")
    end
  end
end
