require 'test_helper'

class RetrievalTest < ActiveSupport::TestCase
  def test_published_on_lazyness 
    # we shouldn't until the day after the publication date
    today = Date.new(2000,1,1)
    article = Article.new(:doi => "10.0/unpublished", 
                          :published_on => today)
    retriever = Retriever.new(:lazy => true)

    # First time we'll call it on the publication date - it should skip out.
    Date.stubs(:today).returns(today)
    Source.expects(:active).never
    retriever.update(article)

    # Second time we'll call it on the day after that - it should look for
    # sources.
    Date.stubs(:today).returns(today + 1)
    Source.expects(:active).returns([])
    retriever.update(article)
  end

  def test_citation_creation
    test_doi = "10.0/citable"
    article = Article.new(:doi => test_doi)
    source = sources(:crossref)
    Source.expects(:active).returns([source])
    test_raw_citations = [
      %w[doi journal_title article_title uri].inject({}) do |h, k|
          h[k.intern] = k
          h
      end
    ]
    verbose = nil # or 1 if you're trying to debug why this test is failing
    retriever_options = { :verbose => verbose } if verbose
    source.expects(:query).with(article, 
                                has_entries(:verbose => verbose,
                                            :retrieval => anything))\
                          .returns(test_raw_citations)
  
    retrieval = Retrieval.new(:source => source,
                              :article => article)
    doomed_citation = Citation.new(:retrieval => retrieval,
                                   :uri => "bogus")
    doomed_citation.save!

    # Before
    assert_equal retrieval.citations, [doomed_citation]
    assert_equal article.citations_count, 1
    assert article.retrieved_at < 1.years.ago

    # Do it
    Retriever.new(retriever_options || {}).update(article)

    # After
    citations = Citation.find_all_by_uri("uri")
    assert_equal citations.size, 1
    citation = citations.first
    assert_equal retrieval.reload.citations, citations
    assert_equal article.reload.citations, citations
    assert_equal article.citations_count, 1
    assert article.retrieved_at > 2.seconds.ago
    assert_equal citation.retrieval, retrieval
  end
end
