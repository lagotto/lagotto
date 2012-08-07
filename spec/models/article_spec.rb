require 'spec_helper'

describe Article do
  
  before do
    @article = Article.new :doi => "10.0/dummy"
  end

  it "save" do
    @article.save.should_not be nil
    @article.errors.empty?.should_not be nil
    assert(@article.retrieval_statuses.size == Source.all.count)
  end

  it "require doi" do
    @article.doi = nil
    @article.save.should_not be true
    @article.errors.messages.has_key?(:doi).should_not be nil
  end

  it "require doi uniqueness" do
    @article.save.should_not be nil
    @article2 = Article.new :doi => "10.0/dummy"
    @article2.save.should_not be true
    @article2.errors.messages.has_key?(:doi).should_not be nil
  end

  it "validate doi format" do
    @article.doi = "asdfasdfasdf"
    @article.save.should_not be true
    @article.errors.messages.has_key?(:doi).should_not be nil
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
    (Article.cited(1).count + Article.cited(0).count).should equal(Article.count)
    Article.cited(nil).count.should == Article.count
    Article.cited('blah').count.should == Article.count
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
