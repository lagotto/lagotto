require 'test_helper'

class RetrievalTest < ActiveSupport::TestCase
  def test_update_should_properly_add_citations
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
    source.expects(:query).with(article).returns(test_raw_citations)
  
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
    Retriever.new.update(article)

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
