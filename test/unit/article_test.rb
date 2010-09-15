# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    assert_equal [articles(:uncited_with_no_retrievals), articles(:stale)],
      Article.stale_and_published
  end

  def test_should_be_stale_based_on_retrieval_age
    check_staleness(articles(:stale)) { |a| a.retrievals.first.update_attribute :retrieved_at, 2.years.ago }
  end

  def test_staleness_on_new
    a = Article.new
    assert a.errors.empty?
    assert a.stale?
  end

  def test_staleness_on_create
    a = Article.create :doi => '10.1/foo'
    assert a.errors.empty?, a.errors.full_messages
    assert a.stale?

    a.published_on = 1.day.ago
    assert a.save
    assert Article.stale_and_published.include?(a)
  end

  def test_staleness_excluding_failed_retrievals
    a = Article.create :doi => '10.1/foo', :published_on => 1.day.ago
    assert a.errors.empty?, a.errors.full_messages
    assert a.stale?

    r = a.retrievals.create :source => sources(:connotea)
    assert r.errors.empty?
    assert_equal nil, r.retrieved_at
    assert Article.stale_and_published.include?(a)
  end

  def test_staleness_excludes_disabled_sources
    Source.update_all :disable_until => 3.days.from_now
    assert_equal [articles(:uncited_with_no_retrievals)], Article.stale_and_published
    Source.update_all :disable_until => 1.hour.from_now
    assert_equal [articles(:uncited_with_no_retrievals)], Article.stale_and_published
    Source.update_all :disable_until => 1.second.ago
    assert_equal 2, Article.stale_and_published.count
  end

  def test_cited
    cited = Article.cited(1)
    assert cited.size > 0
    cited.each do |a|
      assert a.citations_count > 0
    end
  end

  def test_uncited
    uncited = Article.cited(0)
    assert uncited.size > 0
    uncited.each do |a|
      assert_equal 0, a.citations_count
    end
  end

  def test_cited_consistency
    assert_equal Article.count, Article.cited(1).count + Article.cited(0).count
    assert_equal Article.count, Article.cited(nil).count
    assert_equal Article.count, Article.cited('blah').count
  end

  def check_staleness(article, &block)
    article.update_attribute :retrieved_at, 1.minute.ago
    article.retrievals.each {|r| r.update_attribute :retrieved_at, 1.minute.ago }
    assert !article.stale?
    yield article
    assert article.stale?
  end
end
