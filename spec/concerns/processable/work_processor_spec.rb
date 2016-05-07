require "rails_helper"

describe Deposit, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  let!(:registration_agency) { FactoryGirl.create(:registration_agency) }
  let!(:registration_agency_datacite) { FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite") }

  describe "update_work" do
    it "should be created" do
      expect(subject.update_work).to be true
      expect(subject.error_messages).to be_nil

      expect(Work.count).to eq(1)
      expect(Deposit.count).to eq(1)

      expect(subject.work.pid).to eq("http://www.citeulike.org/user/dbogartoit")
    end
  end

  describe "update_related_work" do
    it "should be created" do
      expect(subject.update_related_work).to be true
      expect(subject.error_messages).to be_nil

      expect(Work.count).to eq(1)
      expect(Deposit.count).to eq(1)

      expect(subject.related_work.pid).to eq("http://doi.org/10.1371/JOURNAL.PMED.0030186")
    end
  end

  describe "from_csl" do
    it "should parse subj" do
      expect(subject.from_csl(subject.subj)).to eq(canonical_url: "http://www.citeulike.org/user/dbogartoit",
                                                   title: "CiteULike bookmarks for user dbogartoit",
                                                   year: 2006,
                                                   month: 6,
                                                   day: 13,
                                                   issued_at: "2006-06-13 16:14:19 UTC",
                                                   tracked: false,
                                                   csl: { "author"=>[{"given"=>"dbogartoit"}],
                                                          "container-title"=>"CiteULike"})
    end

    it "should parse an empty subj" do
      expect(subject.from_csl({})).to eq(csl: {"author"=>[]})
    end
  end
end
