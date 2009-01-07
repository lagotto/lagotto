require 'test_helper'

class DoiTest < ActiveSupport::TestCase
  def setup
    @doi = "10.0/dummy"
    @doi_uri = "info:doi/#{@doi}"
    @doi_url = "http://dx.doi.org/#{@doi}"
  end

  def test_should_convert_from_uri
    assert_equal DOI::from_uri(@doi), @doi
    assert_equal DOI::from_uri(@doi_uri), @doi
    assert_equal DOI::from_uri(@doi_url), @doi
    assert_nil DOI::from_uri(nil)
  end

  def test_should_convert_to_uri
    assert_equal DOI::to_uri(@doi), @doi_uri
    assert_equal DOI::to_uri(@doi_uri), @doi_uri
    assert_equal DOI::to_uri(@doi_url), @doi_uri
    assert_nil DOI::to_uri(nil)
  end

  def test_should_convert_to_url
    assert_equal DOI::to_url(@doi), @doi_url
  end
end
