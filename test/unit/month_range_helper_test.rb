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
