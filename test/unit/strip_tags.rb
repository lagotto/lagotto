

require 'test_helper'

class StripTagsTest < ActiveSupport::TestCase
  def test_strip_tags
    assert_equal "<article>This</article> <verb>is</verb> a <noun>test</noun>.".strip_tags,
                 "This is a test."
  end

  def test_strip_nested_tags
    assert_equal "<subject>This string</subject> <predicate>has <adjective>nested</adjective> tags.</predicate>".strip_tags,
                 "This string has nested tags."
  end

  def test_strip_without_tags
    assert_equal "This is a test".strip_tags,
                 "This is a test"
  end
end
