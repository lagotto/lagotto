require 'test_helper'
require 'ruby_debug'

class MonthRangeHelperTest < ActiveSupport::TestCase
  include MonthRangeHelper

  def test_should_iterate_months_up
    assert_equal month_range(Date.civil(2008, 12, 30),
                             Date.civil(2009, 2, 1)).to_a, [
      Date.civil(2008, 12, 1),
      Date.civil(2009, 1,  1),
      Date.civil(2009, 2,  1),
    ]
  end

  def test_should_iterate_months_down
    assert_equal month_range(Date.civil(2009, 3, 1), 
                             Date.civil(2008, 11, 5)).to_a, [
      Date.civil(2009, 3,  1),
      Date.civil(2009, 2,  1),
      Date.civil(2009, 1,  1),
      Date.civil(2008, 12, 1),
      Date.civil(2008, 11, 1),
    ]
  end

  def test_should_handle_single_month
    assert_equal month_range(Date.civil(2009, 1, 1), 
                             Date.civil(2009, 1, 6)).to_a, [
      Date.civil(2009, 1, 1)
    ]
  end
end
