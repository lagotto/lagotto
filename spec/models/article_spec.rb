require 'spec_helper'

describe Article do
  
  before do
    @article = FactoryGirl.create(:article)
  end
  
  subject { @article }
  
  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  it { should validate_uniqueness_of(:doi) }
  it { should validate_presence_of(:published_on) }
  it { should validate_presence_of(:title) }
  
  # TODO make shoulda_matcher work
  #it { should validate_format_of(:doi).with(DOI::FORMAT) }
  it "validate doi format" do
    invalid_doi = build(:article, :cited, :doi => "asdfasdfasdf")
    invalid_doi.should_not be_valid
  end
  
  it 'validate published_on can\'t be too far in the future' do 
    article_in_future = build(:article, :cited, :published_on => 4.months.since)
    article_in_future.should_not be_valid
  end
  
  it 'validate published_on can\'t be too far in the past' do 
    article_in_past = build(:article, :cited, :published_on => 51.years.ago)
    article_in_past.should_not be_valid
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

  it "cited" do
    articles = Article.cited(1)
    articles.each do |article|
      assert(article.events_count > 0)
    end
  end

  it "uncited" do
    articles = Article.cited(0)
    articles.each do |article|
      assert(article.events_count == 0)
    end
  end

  it "cited consistency" do
    #(Article.cited(1).count + Article.cited(0).count).should equal(Article.count)
    #Article.cited(nil).count.should == Article.count
    #Article.cited('blah').count.should == Article.count
  end

  it "query" do

  end

  it "order by doi" do
    articles = Article.order_articles("doi")
    i = 0
    while i < (articles.size-1)
      assert(articles[i].doi < articles[i+1].doi)
      i += 1
    end
  end

  it "order by published_on" do
    articles = Article.order_articles("published_on")
    i = 0
    while i < (articles.size-1)
      assert(articles[i].published_on <= articles[i+1].published_on)
      i += 1
    end
  end

end
