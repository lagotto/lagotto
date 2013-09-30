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

class ApiResponseTooSlowError < Filter

  validates_not_blank(:limit)

  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).slow(limit)

    if responses.count > 0
      responses = responses.all.map { |response| { source_id: response.source_id,
                                                   article_id: response.article_id,
                                                   message: "API response took #{response.duration} ms" }}
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "limit", field_type: "text_field", field_hint: "Raise an error if successful API responses took longer than the specified time in seconds." }]
  end

  def limit
    config.limit || 30
  end

  def limit=(value)
    config.limit = value
  end
end

module Exceptions
  class ApiResponseTooSlowError < ApiResponseError; end
end
