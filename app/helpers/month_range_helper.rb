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

module MonthRangeHelper
  class MonthRange
    include Enumerable
    def initialize(first_date, last_date)
      @first = Date.civil(first_date.year, first_date.month, 1)
      @last = Date.civil(last_date.year, last_date.month, 1)
      @offset = (@first > @last) ? -1 : 1
    end

    def each
      d = @first
      loop do
        yield d
        d >>= @offset
        break if (d <=> @last) == @offset 
      end
    end

    # Ruby 1.8.6 doesn't have Enumerable#count
    unless self.instance_methods.include?("count")
      def count
        to_a.size
      end
    end
  end

  def month_range(start_date, end_date)
    MonthRange.new(start_date, end_date)
  end
end
