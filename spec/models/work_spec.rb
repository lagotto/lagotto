require 'rails_helper'

describe Work, type: :model, vcr: true do

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.5555/12345678", doi: "10.5555/12345678") }

  subject { work }

  it { is_expected.to have_many(:relations).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:doi).case_insensitive }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  context "validate doi format" do
    it "10.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.5555/12345678")
      expect(work).to be_valid
    end

    it "10.13039/100000001" do
      work = FactoryGirl.build(:work, :doi => "10.13039/100000001")
      expect(work).to be_valid
    end

    it "10.1386//crre.4.1.53_1" do
      work = FactoryGirl.build(:work, :doi => " 10.1386//crre.4.1.53_1")
      expect(work).not_to be_valid
    end

    it "10.555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.555/12345678")
      expect(work).not_to be_valid
    end

    it "8.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "8.5555/12345678")
      expect(work).not_to be_valid
    end

    it "10.asdf/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.asdf/12345678")
      expect(work).not_to be_valid
    end

    it "10.5555" do
      work = FactoryGirl.build(:work, :doi => "10.5555")
      expect(work).not_to be_valid
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, :doi => "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "validate url format" do
    it "http://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "http://example.com/1234")
      expect(work).to be_valid
    end

    it "https://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "http://example.com/1234")
      expect(work).to be_valid
    end

    it "ftp://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "ftp://example.com/1234")
      expect(work).not_to be_valid
    end

    it "http://" do
      work = FactoryGirl.build(:work, :canonical_url => "http://")
      expect(work).not_to be_valid
      #expect{work}.to raise_error(Addressable::URI::InvalidURIError)
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, :canonical_url => "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "validate github" do
    it "https://github.com/lagotto/lagotto/tree/v.4.3" do
      work = FactoryGirl.build(:work, pid: "https://github.com/lagotto/lagotto/tree/v.4.3", doi: nil, canonical_url: "https://github.com/lagotto/lagotto/tree/v.4.3")
      expect(work).to be_valid
    end
  end

  context "validate ark format" do
    it "ark:/13030/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => "ark:/13030/m5br8stc")
      expect(work).to be_valid
    end

    it "13030/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => " 13030/m5br8stc")
      expect(work).not_to be_valid
    end

    it "ark:/13030" do
      work = FactoryGirl.build(:work, :ark => "ark:/13030")
      expect(work).not_to be_valid
    end

    it "ark:/1303x/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => "ark:/1303x/m5br8stc")
      expect(work).not_to be_valid
    end
  end

  context "validate date" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it 'validate date' do
      work = FactoryGirl.build(:work)
      expect(work).to be_valid
    end

    it 'validate date with missing day' do
      work = FactoryGirl.build(:work, day: nil)
      expect(work).to be_valid
    end

    it 'validate date with missing month and day' do
      work = FactoryGirl.build(:work, month: nil, day: nil)
      expect(work).to be_valid
    end

    it 'look up date for missing year, month and day' do
      work = FactoryGirl.build(:work, year: nil, month: nil, day: nil, pid: "http://doi.org/10.1371/journal.pone.0067729")
      expect(work).to be_valid
    end

    it 'don\'t validate wrong date' do
      work = FactoryGirl.build(:work, month: 2, day: 30)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["is not a valid date"])
    end

    it 'don\'t validate date in the future' do
      date = Time.zone.now.to_date + 1.day
      work = FactoryGirl.build(:work, year: date.year, month: date.month, day: date.day)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["is a date in the future"])
    end

    it 'published_on' do
      work = FactoryGirl.create(:work)
      date = Date.new(work.year, work.month, work.day)
      expect(work.published_on).to eq(date)
    end

    it 'issued' do
      work = FactoryGirl.create(:work)
      date = { "date-parts" => [[work.year, work.month, work.day]] }
      expect(work.issued).to eq(date)
    end

    it 'issued_date year month day' do
      work = FactoryGirl.create(:work, year: 2013, month: 2, day: 9)
      expect(work.issued_date).to eq("February 9, 2013")
    end

    it 'issued_date year month' do
      work = FactoryGirl.create(:work, year: 2013, month: 2, day: nil)
      expect(work.issued_date).to eq("February 2013")
    end

    it 'issued_date year' do
      work = FactoryGirl.create(:work, year: 2013, month: nil, day: nil)
      expect(work.issued_date).to eq("2013")
    end
  end

  context "sanitize title" do
    it "strips tags and attributes" do
      title = '<span id="date">2013-12-05</span'
      work = FactoryGirl.create(:work, title: title)
      expect(work.title).to eq("2013-12-05")
    end

    it "keeps allowed tags" do
      title = "Characterization of the Na<sup>+</sup>/H<sup>+</sup> Antiporter from <i>Yersinia pestis</i>"
      work = FactoryGirl.create(:work, title: title)
      expect(work.title).to eq(title)
    end
  end

  it 'to doi escaped' do
    expect(CGI.escape(work.doi)).to eq(work.doi_escaped)
  end

  it 'to title escaped' do
    expect(CGI.escape(work.title.to_str).gsub("+", "%20")).to eq(work.title_escaped)
  end

  it 'event_count' do
    work = FactoryGirl.create(:work_with_twitter)
    expect(work.event_count('is_discussed_by')).to eq(25)
  end

  it 'is_viewed_by' do
    work = FactoryGirl.create(:work_with_counter)
    expect(work.is_viewed_by).to eq(500)
  end

  it 'is_discussed_by' do
    work = FactoryGirl.create(:work_with_twitter)
    expect(work.is_discussed_by).to eq(25)
  end

  it 'is_bookmarked_by' do
    work = FactoryGirl.create(:work_with_mendeley)
    expect(work.is_bookmarked_by).to eq(10)
  end

  it 'is_cited_by' do
    work = FactoryGirl.create(:work_with_crossref)
    expect(work.is_cited_by).to eq(25)
  end

  it 'metrics' do
    work = FactoryGirl.create(:work_with_crossref_and_mendeley)
    expect(work.metrics).to eq("crossref"=>25, "mendeley"=>10)
  end

  it "events count" do
    Work.all.each do |work|
      total = work.events.reduce(0) { |sum, rs| sum + rs.event_count }
      expect(total).to eq(work.events_count)
    end
  end

  it "has events" do
    expect(Work.has_events.all? { |work| work.events_count > 0 }).to be true
  end

  context "get_url" do
    it 'should get_url' do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030", canonical_url: nil)
      url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
      expect(work.get_url).not_to be_nil
      expect(work.canonical_url).to eq(url)
    end

    it "with canonical_url" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030")
      expect(work.get_url).to be true
    end

    it "without doi" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(work.get_url).to be false
      expect(work.canonical_url).to be_nil
    end
  end

  it 'should get_ids' do
    work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: nil)
    expect(work.get_ids).to be true
    expect(work.pmid).to eq("17183658")
  end

  it "should get all_urls" do
    work = FactoryGirl.build(:work, :canonical_url => "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000001")
    expect(work.all_urls).to eq([work.canonical_url, work.pmid_as_europepmc_url].compact + work.provenance_urls)
  end

  context "associations" do
    it "should create associated aggregations" do
      expect(Aggregation.count).to eq(0)
      @works = FactoryGirl.create_list(:work, 2, :with_events)
      expect(Aggregation.count).to eq(2)
    end

    it "should delete associated aggregations" do
      @works = FactoryGirl.create_list(:work, 2, :with_events)
      expect(Aggregation.count).to eq(2)
      @works.each(&:destroy)
      expect(Aggregation.count).to eq(0)
    end

    it "should create associated relations" do
      expect(Relation.count).to eq(0)
      @works = FactoryGirl.create_list(:work, 2, :with_relations)
      expect(Relation.count).to eq(10)
    end

    it "should delete associated relations" do
      @works = FactoryGirl.create_list(:work, 2, :with_relations)
      expect(Relation.count).to eq(10)
      @works.each(&:destroy)
      expect(Relation.count).to eq(0)
    end
  end
end
