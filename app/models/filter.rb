# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
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

require 'ostruct'

class Filter < ActiveRecord::Base
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::TextHelper

  has_many :reviews, :primary_key => "name", :foreign_key => "name"

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true

  default_scope order("name")
  scope :active, where(:active => true)

  class << self

    def all
      # To sync filters
      # Only run filter if we have unresolved API responses
      options = { id: ApiResponse.unresolved.maximum(:id),
                  input: ApiResponse.unresolved.count(:id),
                  output: 0,
                  started_at: ApiResponse.unresolved.minimum(:created_at),
                  ended_at: ApiResponse.unresolved.maximum(:created_at),
                  review_messages: [] }

      return nil unless options[:id]

      Filter.active.each do |filter|

        options[:name] = filter.name
        options[:display_name] = filter.display_name
        options[:time] = Benchmark.realtime {options[:output] = filter.run_filter(options) }
        options[:message] = formatted_message(options)
        options[:review_messages] << create_review(options)
      end

      resolve(options.except(:name, :display_name))
    end

    def formatted_message(options)
      formatted_input = pluralize(number_with_delimiter(options[:input]), 'API response')
      formatted_output = pluralize(number_with_delimiter(options[:output]), options[:display_name])
      formatted_time = number_with_precision(options[:time] * 1000)

      "Found #{formatted_output} in #{formatted_input}, taking #{formatted_time} ms"
    end

    def create_review(options)
      review = Review.find_or_initialize_by_name_and_state_id(name: options[:name], state_id: options[:id])
      review.update_attributes(message: options[:message],
                               input: options[:input],
                               output: options[:output],
                               started_at: options[:started_at],
                               ended_at: options[:ended_at])
      options[:message]
    end

    def resolve(options)
      options[:time] = Benchmark.realtime {options[:output] = ApiResponse.filter(options[:id]).update_all(unresolved: false) }
      options[:message] = "Resolved #{pluralize(number_with_delimiter(options[:output]), 'API response')} in #{number_with_precision(options[:time] * 1000)} ms"
      options
    end

    def unresolve(options = {})
      options[:time] = Benchmark.realtime { options[:output] = ApiResponse.update_all(unresolved: true) }
      options[:id] = ApiResponse.maximum(:id)
      options[:message] = "Unresolved #{pluralize(number_with_delimiter(options[:output]), 'API response')} in #{number_with_precision(options[:time] * 1000)} ms"
      options
    end
  end

  def get_config_fields
    []
  end

  def status
    (active ? "active" : "inactive")
  end

  def run_filter(options = {})
    raise NotImplementedError, 'Children classes should override run_filter method'
  end

  def raise_alerts(responses)
    responses.each do |response|
      alert = Alert.find_or_initialize_by_class_name_and_article_id_and_source_id(class_name: name,
                                                                                  source_id: response[:source_id],
                                                                                  article_id: response[:article_id])
      alert.update_attributes(exception: "", error: !response[:error], message: response[:message] ? response[:message] : "An API response error occured")
    end
  end
end

module Exceptions
  # Default filter error
  class ApiResponseError < StandardError; end
end
