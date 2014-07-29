require 'spec_helper'

describe Article do

  let(:article) { FactoryGirl.create(:article) }

  subject { article }

  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  it { should validate_uniqueness_of(:doi) }
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:title) }
  it { should validate_numericality_of(:year).only_integer }

  it "validate doi format" do
    invalid_doi = FactoryGirl.build(:article, :doi => "asdfasdfasdf")
    invalid_doi.should_not be_valid
  end

  it 'validate date' do
    article = FactoryGirl.build(:article, day: 25)
    article.should be_valid
  end

  it 'validate date with missing day' do
    article = FactoryGirl.build(:article, day: nil)
    article.should be_valid
  end

  it 'validate date with missing month and day' do
    article = FactoryGirl.build(:article, month: nil, day: nil)
    article.should be_valid
  end

  it 'don\'t validate wrong date' do
    article = FactoryGirl.build(:article, month: 2, day: 30)
    article.should_not be_valid
    article.errors[:published_on].should eq(["is not a valid date"])
  end

  it 'don\'t validate date in the future' do
    date = Date.today + 1.day
    article = FactoryGirl.build(:article, year: date.year, month: date.month, day: date.day)
    article.should_not be_valid
    article.errors[:published_on].should eq(["is a date in the future"])
  end

  it 'published_on' do
    article = FactoryGirl.create(:article)
    date = Date.new(article.year, article.month, article.day)
    article.published_on.should eq(date)
  end

  it 'issued' do
    article = FactoryGirl.create(:article)
    date = { "date-parts" => [[article.year, article.month, article.day]] }
    article.issued.should eq(date)
  end

  it 'issued_date year month day' do
    article = FactoryGirl.create(:article, year: 2013, month: 2, day: 9)
    article.issued_date.should eq("February 9, 2013")
  end

  it 'issued_date year month' do
    article = FactoryGirl.create(:article, year: 2013, month: 2, day: nil)
    article.issued_date.should eq("February 2013")
  end

  it 'issued_date year' do
    article = FactoryGirl.create(:article, year: 2013, month: nil, day: nil)
    article.issued_date.should eq("2013")
  end

  it 'sanitize title' do
    article = FactoryGirl.create(:article, title: "<italic>Test</italic>")
    article.title.should eq("Test")
  end

  it 'to doi escaped' do
    CGI.escape(article.doi).should eq(article.doi_escaped)
  end

  it 'doi as url' do
    Addressable::URI.encode("http://dx.doi.org/#{article.doi}").should eq(article.doi_as_url)
  end

  it 'to_uri' do
    Article.to_uri(article.doi).should eq "info:doi/#{article.doi}"
  end

  it 'to_url' do
    Article.to_url(article.doi).should eq "http://dx.doi.org/#{article.doi}"
  end

  it 'to title escaped' do
    CGI.escape(article.title.to_str).gsub("+", "%20").should eq(article.title_escaped)
  end

  it "events count" do
    Article.all.each do |article|
      total = article.retrieval_statuses.reduce(0) { |sum, rs| sum + rs.event_count }
      total.should == article.events_count
    end
  end

  it "cited_retrievals_count" do
    Article.all.each do |article|
      total = article.retrieval_statuses.reduce(0) { |sum, rs| sum + 1 if rs.event_count > 0 }
      total.should == article.cited_retrievals_count
    end
  end

  it "is cited" do
    Article.is_cited.all? { |article| article.events_count > 0 }.should be_true
  end

  it 'should get_url' do
    article = FactoryGirl.create(:article, canonical_url: nil)
    url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
    stub = stub_request(:get, "http://dx.doi.org/#{article.doi}").to_return(:status => 302, :headers => { 'Location' => url })
    stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
    article.get_url.should be_true
    article.canonical_url.should eq(url)
  end

  it 'should get_ids' do
    article = FactoryGirl.create(:article, pmid: nil)
    pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
    stub = stub_request(:get, pubmed_url).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'persistent_identifiers.json'), :status => 200)
    article.get_ids.should be_true
    article.pmid.should eq("17183658")
    stub.should have_been_requested
  end

  it "should get all_urls" do
    article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
    article.all_urls.should eq([article.doi_as_url, article.canonical_url])
  end

  context "associations" do
    it "should create associated retrieval_statuses" do
      RetrievalStatus.count.should == 0
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      RetrievalStatus.count.should == 2
    end

    it "should delete associated retrieval_statuses" do
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      RetrievalStatus.count.should == 2
      @articles.each { |article| article.destroy }
      RetrievalStatus.count.should == 0
    end
  end

end
