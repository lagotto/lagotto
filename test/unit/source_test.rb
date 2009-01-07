require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  def test_should_report_configured_sources
    # (This assumes we just have only the CrossRef fixture)
    assert_equal Source.all, [sources(:crossref)]
  end

  def test_should_report_unconfigured_subclasses
    assert Source.unconfigured_source_names.include?("Bloglines")
  end

  def test_should_calculate_staleness_limit
    assert_equal Source.maximum_staleness, 1.year
  end
end
