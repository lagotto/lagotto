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

module Measurable
  extend ActiveSupport::Concern

  included do

    # create a hash with the different metrics categories
    # total is sum of all categories if no total value is provided
    # make sure all values are either integers or nil
    def get_event_metrics(options = {})
      options = Hash[ options.map { |key, value| [key.to_sym, value.nil? ? nil : value.to_i] } ]
      options[:total] ||= options.values.sum

      { :pdf => options[:pdf],
        :html => options[:html],
        :shares => options[:shares],
        :groups => options[:groups],
        :comments => options[:comments],
        :likes => options[:likes],
        :citations => options[:citations],
        :total => options[:total] }
    end

    def get_sum(items, key)
      items.empty? ? 0 : items.reduce(0) { |sum, hash| sum + hash[key].to_i }
    end

  end
end
