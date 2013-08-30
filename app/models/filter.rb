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

      result = { decreasing: 0, increasing: 0, slow: 0, resolve: 0 }

      # To avoid racing conditions
      id = last_id

      return result unless id

      result[:decreasing] = decreasing(id)
      result[:increasing] = increasing(id)
      result[:slow] = slow(id)
      result[:resolve] = resolve(id)

      result
    end

    def last_id
      ApiResponse.maximum(:id)
    end

    def decreasing(id)
      responses = ApiResponse.filter(id).decreasing
      if responses.count > 0
        raise_errors(responses, class_name: "EventCountDecreasingError",
                                message: "The event count has decreased")
      end
      responses.count
    end

    def increasing(id, limit = 1000)
      responses = ApiResponse.filter(id).increasing(limit)

      if responses.count > 0
        raise_errors(responses, class_name: "EventCountIncreasingTooFastError",
                                message: "The event count has increased too fast (by at least #{limit})")
      end
      responses.count
    end

    def slow(id, limit = 15)
      responses = ApiResponse.filter(id).slow(limit)

      if responses.count > 0
        raise_errors(responses, class_name: "ApiResponseTooSlowError",
                                message: "The API response was too slow (at least #{limit}) seconds")
      end
      responses.count
    end

    def resolve(id)
      ApiResponse.filter(id).update_all(unresolved: false)
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
end
