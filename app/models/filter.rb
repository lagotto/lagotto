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

class Filter
  class << self

    def all

      # To avoid race conditions
      id = last_id
      result = []

      return result unless id

      result << decreasing(id)
      result << increasing(id)
      result << slow(id)
      result << not_updated(id)
      result << resolve(id)
    end

    def last_id
      ApiResponse.maximum(:id)
    end

    def decreasing(id)
      class_name = "EventCountDecreasingError"
      responses = ApiResponse.filter(id).decreasing
      message = "Event count decreased"
      sum_message = "Found #{responses.count} decreasing event count error(s)"

      raise_errors(responses, class_name: class_name, message: message) if responses.count > 0

      { class_name: class_name, result: responses.count, message: sum_message }
    end

    def increasing(id, limit = 1000)
      class_name = "EventCountIncreasingTooFastError"
      responses = ApiResponse.filter(id).increasing(limit)
      message = "Event count increased too fast"
      sum_message = "Found #{responses.count} increasing event count error(s)"

      raise_errors(responses, class_name: class_name, message: message) if responses.count > 0

      { class_name: class_name, result: responses.count, message: sum_message }
    end

    def slow(id, limit = 15)
      class_name = "ApiResponseTooSlowError"
      responses = ApiResponse.filter(id).slow(limit)
      message = "API response too slow"
      sum_message = "Found #{responses.count} API too slow error(s)"

      raise_errors(responses, class_name: class_name, message: message) if responses.count > 0

      { class_name: class_name, result: responses.count, message: sum_message }
    end

    def not_updated(id, limit = 40)
      class_name = "ArticleNotUpdatedError"
      responses = ApiResponse.filter(id).not_updated(limit)
      message = "Article not updated for too long"
      sum_message = "Found #{responses.count} article not updated error(s)"

      raise_errors(responses, class_name: class_name, message: message) if responses.count > 0

      { class_name: class_name, result: responses.count, message: sum_message }
    end

    def resolve(id)
      count = ApiResponse.filter(id).update_all(unresolved: false)
      sum_message = "Resolved #{count} API response(s)"

      { class_name: nil, result: count, message: sum_message }
    end

    def raise_errors(responses, options = { class_name: "ApiResponseError", message: "An error occured in the API response" })
      responses.each do |response|
        ErrorMessage.create(exception: "",
                            class_name: options[:class_name],
                            message: options[:message],
                            source_id: response.source_id,
                            article_id: response.article_id)
      end
    end
  end
end

module Exceptions
  # class of errors in API responses
  class ApiResponseError < StandardError; end

  # the event count received from a source is decreasing
  class EventCountDecreasingError < ApiResponseError; end

  # the event count received from a source is increasing too fast
  class EventCountIncreasingTooFastError < ApiResponseError; end

  # the API took too long to respond
  class ApiResponseTooSlowError < ApiResponseError; end

  # the article was not updated for too long
  class ArticleNotUpdatedError < ApiResponseError; end
end
