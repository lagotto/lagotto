require 'rails_helper'

describe Article, :type => :model do

  let(:article) { FactoryGirl.create(:article) }

  subject { article }

  it { is_expected.to have_many(:retrieval_statuses).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:doi) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  context "validate doi format" do
    it "10.5555/12345678" do
      article = FactoryGirl.build(:article, :doi => "10.5555/12345678")
      expect(article).to be_valid
    end

    it "10.13039/100000001" do
      article = FactoryGirl.build(:article, :doi => "10.13039/100000001")
      expect(article).to be_valid
    end

    it "10.1386//crre.4.1.53_1" do
      article = FactoryGirl.build(:article, :doi => " 10.1386//crre.4.1.53_1")
      expect(article).to be_valid
    end

    it "10.555/12345678" do
      article = FactoryGirl.build(:article, :doi => "10.555/12345678")
      expect(article).not_to be_valid
    end

    it "8.5555/12345678" do
      article = FactoryGirl.build(:article, :doi => "8.5555/12345678")
      expect(article).not_to be_valid
    end

    it "10.asdf/12345678" do
      article = FactoryGirl.build(:article, :doi => "10.asdf/12345678")
      expect(article).not_to be_valid
    end

    it "10.5555" do
      article = FactoryGirl.build(:article, :doi => "10.5555")
      expect(article).not_to be_valid
    end

    it "asdfasdfasdf" do
      article = FactoryGirl.build(:article, :doi => "asdfasdfasdf")
      expect(article).not_to be_valid
    end
  end

  context "validate date " do
    before(:each) { allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5)) }

    it 'validate date' do
      article = FactoryGirl.build(:article)
      expect(article).to be_valid
    end

    it 'validate date with missing day' do
      article = FactoryGirl.build(:article, day: nil)
      expect(article).to be_valid
    end

    it 'validate date with missing month and day' do
      article = FactoryGirl.build(:article, month: nil, day: nil)
      expect(article).to be_valid
    end

    it 'don\'t validate date with missing year, month and day' do
      article = FactoryGirl.build(:article, year: nil, month: nil, day: nil)
      expect(article).not_to be_valid
      expect(article.errors.messages).to eq(year: ["is not a number", "should be between 1650 and 2014"])
    end

    it 'don\'t validate wrong date' do
      article = FactoryGirl.build(:article, month: 2, day: 30)
      expect(article).not_to be_valid
      expect(article.errors.messages).to eq(published_on: ["is not a valid date"])
    end

    it 'don\'t validate date in the future' do
      date = Date.today + 1.day
      article = FactoryGirl.build(:article, year: date.year, month: date.month, day: date.day)
      expect(article).not_to be_valid
      expect(article.errors.messages).to eq(published_on: ["is a date in the future"])
    end

    it 'published_on' do
      article = FactoryGirl.create(:article)
      date = Date.new(article.year, article.month, article.day)
      expect(article.published_on).to eq(date)
    end

    it 'issued' do
      article = FactoryGirl.create(:article)
      date = { "date-parts" => [[article.year, article.month, article.day]] }
      expect(article.issued).to eq(date)
    end

    it 'issued_date year month day' do
      article = FactoryGirl.create(:article, year: 2013, month: 2, day: 9)
      expect(article.issued_date).to eq("February 9, 2013")
    end

    it 'issued_date year month' do
      article = FactoryGirl.create(:article, year: 2013, month: 2, day: nil)
      expect(article.issued_date).to eq("February 2013")
    end

    it 'issued_date year' do
      article = FactoryGirl.create(:article, year: 2013, month: nil, day: nil)
      expect(article.issued_date).to eq("2013")
    end
  end

  it 'sanitize title' do
    article = FactoryGirl.create(:article, title: "<italic>Test</italic>")
    expect(article.title).to eq("Test")
  end

  it 'to doi escaped' do
    expect(CGI.escape(article.doi)).to eq(article.doi_escaped)
  end

  it 'doi as url' do
    expect(Addressable::URI.encode("http://dx.doi.org/#{article.doi}")).to eq(article.doi_as_url)
  end

  it 'to_uri' do
    expect(Article.to_uri(article.doi)).to eq "info:doi/#{article.doi}"
  end

  it 'to_url' do
    expect(Article.to_url(article.doi)).to eq "http://dx.doi.org/#{article.doi}"
  end

  it 'to title escaped' do
    expect(CGI.escape(article.title.to_str).gsub("+", "%20")).to eq(article.title_escaped)
  end

  it "events count" do
    Article.all.each do |article|
      total = article.retrieval_statuses.reduce(0) { |sum, rs| sum + rs.event_count }
      expect(total).to eq(article.events_count)
    end
  end

  it "with events" do
    expect(Article.with_events.all? { |article| article.events_count > 0 }).to be true
  end

  it 'should get_url' do
    article = FactoryGirl.create(:article, canonical_url: nil)
    url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
    stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
    stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
    expect(article.get_url).not_to be_nil
    expect(article.canonical_url).to eq(url)
  end

  it 'should get_ids' do
    article = FactoryGirl.create(:article, pmid: nil)
    pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
    stub = stub_request(:get, pubmed_url).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'persistent_identifiers.json'), :status => 200)
    expect(article.get_ids).to be true
    expect(article.pmid).to eq("17183658")
    expect(stub).to have_been_requested
  end

  it "should get all_urls" do
    article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
    expect(article.all_urls).to eq([article.doi_as_url, article.canonical_url])
  end

  context "associations" do
    it "should create associated retrieval_statuses" do
      expect(RetrievalStatus.count).to eq(0)
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      expect(RetrievalStatus.count).to eq(2)
    end

    it "should delete associated retrieval_statuses" do
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      expect(RetrievalStatus.count).to eq(2)
      @articles.each(&:destroy)
      expect(RetrievalStatus.count).to eq(0)
    end
  end

end
