# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

module Dateable
  extend ActiveSupport::Concern

  included do

    # Array of hashes in format [{ month: 12, year: 2013 },{ month: 1, year: 2014 }]
    # Provide starting month and year as input, otherwise defaults to this month
    def self.date_range(options = {})
      end_date = Date.today

      if options[:month] && options[:year]
        Date.new(options[:year].to_i, options[:month].to_i, 1)
        start_date = end_date if start_date > end_date
        (start_date..end_date).map { |date| { month: date.month, year: date.year } }.uniq
      else
        [{ month: end_date.month, year: end_date.year }]
      end
    rescue ArgumentError
      [{ month: end_date.month, year: end_date.year }]
    end

  end
end
