require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @article = Article.new :doi => "10.0/dummy"
  end

  def test_should_save
    assert @article.save
    assert @article.errors.empty?
  end

  def test_should_require_doi
    @article.doi = nil
    assert !@article.save
    assert @article.errors.on(:doi)
  end

  def test_should_require_doi_uniqueness
    assert @article.save
    @article2 = Article.new :doi => "10.0/dummy"
    assert !@article2.save
    assert @article2.errors.on(:doi)
  end

  def test_should_find_stale_articles
    assert_equal Article.not_refreshed_since(Source.maximum_staleness.ago),
                 [articles(:stale)]
  end

  def test_should_be_stale_based_on_article_age
    check_staleness(articles(:stale)) { |a| a.retrieved_at = 1.year.ago }
  end

  def test_should_be_stale_based_on_retrieval_age
    check_staleness(articles(:stale)) { |a| a.retrievals.first.retrieved_at = 2.years.ago }
  end

  def check_staleness(article, &block)
    article.retrieved_at = 1.minute.ago
    article.retrievals.each {|r| r.retrieved_at = 1.minute.ago }
    assert !article.stale?
    yield article
    assert article.stale?
  end
end
