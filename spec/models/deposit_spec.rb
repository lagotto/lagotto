require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_id) }

  describe "attributes" do
    it "year" do
      expect(subject.year).to eq(2015)
    end

    it "month" do
      expect(subject.month).to eq(4)
    end
  end

  describe "from_csl" do
    it "should parse subj" do
      expect(subject.from_csl(subject.subj)).to eq(canonical_url: "http://www.citeulike.org/user/dbogartoit",
                                                   title: "CiteULike bookmarks for user dbogartoit",
                                                   year: 2006,
                                                   month: 6,
                                                   day: 13,
                                                   tracked: false,
                                                   csl: { "author"=>[{"given"=>"dbogartoit"}],
                                                          "container-title"=>"CiteULike"})
    end

    it "should parse an empty subj" do
      expect(subject.from_csl({})).to eq(csl: {"author"=>[]})
    end
  end

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
      #expect(subject.work.related_works.first).to eq(subject.related_work)
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
      #expect(subject.work.related_works.first).to eq(subject.related_work)
      expect(subject.error_messages).to be_nil
    end
  end

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
      contributor = subject.update_contributor
      expect(contributor.orcid).to eq("0000-0002-0159-2197")
      expect(contributor.credit_name).to eq("Jonathan A. Eisen")
      expect(subject.error_messages).to be_nil
    end

    it "update invalid orcid" do
      subject = FactoryGirl.create(:deposit_for_contributor, :invalid_orcid)
      expect(subject.update_contributor).to be false
      expect(subject.error_messages).to eq("contributor"=>"Validation failed: Orcid can't be blank, Orcid is invalid")
    end
  end

  describe "update_publisher" do
    it "update" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      publisher = subject.update_publisher
      expect(publisher.name).to eq("ANDS.CENTRE-1")
      expect(publisher.title).to eq("Griffith University")
      expect(publisher.checked_at.utc.iso8601).to eq("2006-06-13T16:14:19Z")
      expect(subject.error_messages).to be_nil
    end

    it "update missing title" do
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      expect(subject.update_publisher).to be false
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")
    end
  end

  describe "process_data" do
    it "datacite_orcid" do
      FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_datacite_orcid)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "contributor" do
      subject = FactoryGirl.create(:deposit_for_contributor)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "contributor failed" do
      source = FactoryGirl.create(:source, :datacite_orcid)
      subject = FactoryGirl.create(:deposit_for_contributor, :invalid_orcid)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq("contributor"=>"Validation failed: Orcid can't be blank, Orcid is invalid")

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.message).to eq("Validation failed: Orcid can't be blank, Orcid is invalid for contributor 555-1212")
      expect(notification.source_id).to eq(source.id)
    end

    it "publisher" do
      subject = FactoryGirl.create(:deposit_for_publisher)
      subject.process_data
      expect(subject.human_state_name).to eq("done")
      expect(subject.error_messages).to be_nil
    end

    it "publisher failed" do
      source = FactoryGirl.create(:source, :datacite_datacentre)
      subject = FactoryGirl.create(:deposit_for_publisher, :no_publisher_title)
      subject.process_data
      expect(subject.human_state_name).to eq("failed")
      expect(subject.error_messages).to eq("publisher"=>"Validation failed: Title can't be blank")

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.message).to eq("Validation failed: Title can't be blank for publisher ANDS.CENTRE-1")
      expect(notification.source_id).to eq(source.id)
    end
  end
end
