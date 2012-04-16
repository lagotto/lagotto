require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @article = Article.new :doi => "10.0/dummy"
  end

  test "save" do
    assert @article.save
    assert @article.errors.empty?
    assert(@article.retrieval_statuses.size == Source.all.count)
  end

  test "require doi" do
    @article.doi = nil
    assert !@article.save
    assert @article.errors.messages.has_key?(:doi)
  end

  test "require doi uniqueness" do
    assert @article.save
    @article2 = Article.new :doi => "10.0/dummy"
    assert !@article2.save
    assert @article2.errors.messages.has_key?(:doi)
  end

  test "validate doi format" do
    @article.doi = "asdfasdfasdf"
    assert !@article.save
    assert @article.errors.messages.has_key?(:doi)
  end

  test "citations count" do
    Article.all.each do |article|
      total = 0
      article.retrieval_statuses.each do |rs|
        total += rs.event_count
      end
      assert(total == article.citations_count)
    end
  end

  test "cited_retrievals_count" do
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

  test "cited" do
    articles = Article.cited(1)
    articles.each do |article|
      assert(article.citations_count > 0)
    end
  end

  test "uncited" do
    articles = Article.cited(0)
    articles.each do |article|
      assert(article.citations_count == 0)
    end
  end

  test "cited consistency" do
    assert_equal Article.count, Article.cited(1).count + Article.cited(0).count
    assert_equal Article.count, Article.cited(nil).count
    assert_equal Article.count, Article.cited('blah').count
  end

  test "query" do

  end

  test "order by doi" do
    articles = Article.order_articles("doi")
    i = 0
    while i < (articles.size-1)
      assert(articles[i].doi < articles[i+1].doi)
      i += 1
    end
  end

  test "order by published_on" do
    articles = Article.order_articles("published_on")
    i = 0
    while i < (articles.size-1)
      assert(articles[i].published_on <= articles[i+1].published_on)
      i += 1
    end
  end

end
