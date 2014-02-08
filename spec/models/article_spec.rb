require 'spec_helper'

describe Article do

  let(:article) { FactoryGirl.create(:article) }

  subject { article }

  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  it { should validate_uniqueness_of(:doi) }
  it { should validate_presence_of(:published_on) }
  it { should validate_presence_of(:title) }

  # TODO make shoulda_matcher work
  #it { should validate_format_of(:doi).with(FORMAT) }
  it "validate doi format" do
    invalid_doi = build(:article, :cited, :doi => "asdfasdfasdf")
    invalid_doi.should_not be_valid
  end

  it 'validate published_on can\'t be too far in the future' do
    article_in_future = build(:article, :cited, :published_on => 4.months.since)
    article_in_future.should_not be_valid
  end

  it 'validate published_on can\'t be too far in the past' do
    article_in_past = build(:article, :cited, :published_on => Date.new(1600,1,1))
    article_in_past.should_not be_valid
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
      total = 0
      article.retrieval_statuses.each do |rs|
        total += rs.event_count
      end
      assert(total == article.events_count)
    end
  end

  it "cited_retrievals_count" do
    Article.all.each do |article|
      total = 0
      article.retrieval_statuses.each do |rs|
        if rs.event_count > 0
          total += 1
        end
      end
      assert(total == article.cited_retrievals_count)
    end
  end

  it "is cited" do
    articles = Article.is_cited
    articles.each do |article|
      assert(article.events_count > 0)
    end
  end

  it "order by published_on" do
    articles = Article.order_articles("")
    i = 0
    while i < (articles.size-1)
      assert(articles[i].published_on <= articles[i+1].published_on)
      i += 1
    end
  end

  it "should get the all_urls" do
    article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
    article.all_urls.should eq([article.doi_as_url,article.doi_as_publisher_url,article.canonical_url])
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
      @articles.each {|article| article.destroy }
      RetrievalStatus.count.should == 0
    end

    it "should create associated retrieval_histories" do
      RetrievalStatus.count.should == 0
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      RetrievalHistory.count.should == 2
    end

    it "should delete associated retrieval_histories" do
      @articles = FactoryGirl.create_list(:article_with_events, 2)
      RetrievalHistory.count.should == 2
      @articles.each {|article| article.destroy }
      RetrievalHistory.count.should == 0
    end
  end

end
