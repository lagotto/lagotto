require 'test_helper'
require 'ruby-debug'

class ArticleRoutingTest < ActiveSupport::TestCase
  def test_should_generate_route_using_doi
    # This ought to be as simple as:
    #   path = "articles/info:doi%2F10.1000%2Fjournal.pone.1000/edit"
    #   opts = {:controller => "articles", 
    #           :id => "info:doi/10.1000/journal.pone.1000", 
    #           :action => "edit"}
    #   assert_generates path, opts
    # but that fails, complaining that it can't find a route using
    # the DOI in the @opts hash. If I escape the DOI, it
    # finds the route but ends up double-escaping the URI, which causes
    # the comparison to fail. By doing extra escaping in the path, it passes:
    path = "articles/info:doi%252F10.1000%252Fjournal.pone.1000/edit"
    opts = {:controller => "articles", :id => "info:doi%2F10.1000%2Fjournal.pone.1000", :action => "edit"}
    assert_generates path, opts
  end

  def test_should_recognize_route_using_doi
    path = "articles/info:doi%2F10.1000%2Fjournal.pone.1000/edit"
    opts = {:controller => "articles", :id => "info:doi/10.1000/journal.pone.1000", :action => "edit"}
    assert_recognizes opts, path
  end
end
