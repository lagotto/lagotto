require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_id) }

  describe "update_relations" do
    it "citeulike" do
      FactoryGirl.create(:source)
      FactoryGirl.create(:relation_type, :bookmarks)
      FactoryGirl.create(:relation_type, :is_bookmarked_by)
      relations = subject.update_relations
      expect(relations).to eq(2)
      #relations.all? { |relation| expect(relation[:errors]).to be_empty }

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
      FactoryGirl.create(:source, :datacite_related)
      FactoryGirl.create(:relation_type, :has_part)
      FactoryGirl.create(:relation_type, :is_part_of)
      subject = FactoryGirl.create(:deposit_for_datacite_related)
      relations = subject.update_relations
      relations.all? { |relation| expect(relation[:errors]).to be_empty }
    end

    it "datacite_github" do
      FactoryGirl.create(:source, :datacite_github)
      FactoryGirl.create(:relation_type, :is_supplement_to)
      FactoryGirl.create(:relation_type, :has_supplement)
      subject = FactoryGirl.create(:deposit_for_datacite_github)
      relations = subject.update_relations
      expect(relations).to eq(2)
      #relations.all? { |relation| expect(relation[:errors]).to be_empty }
    end
  end

  describe "update_publisher" do
    it "update" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      expect(subject.update_publisher).to eq(:class=>"Publisher", :id=>"ANDS.CENTRE-1", :errors=>[])
    end

    it "update missing title" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      expect(subject.update_publisher).to eq(:class=>"Publisher", :id=>"ANDS.CENTRE-1", :errors=>["Title can't be blank"])
    end
  end

  describe "process_data" do
    it "publisher" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
    end

    it "publisher failed" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq(["Title can't be blank"])
    end
  end
end
