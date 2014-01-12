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

class EventCountIncreasingTooFastError < Filter

  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).increasing(limit, source_ids)

    if responses.count > 0
      responses = responses.all.map { |response| { source_id: response.source_id,
                                                   article_id: response.article_id,
                                                   error: 0,
                                                   message: "Event count increased by #{response.event_count - response.previous_count} in #{response.update_interval} day(s)" }}
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "source_ids" },
     { field_name: "limit", field_type: "text_field", field_hint: "Raises an error if the event count increases faster than the specified value per day." }]
  end

  def limit
    config.limit || 500
  end

  def source_ids
    config.source_ids || Source.active.joins(:group).where("groups.name IN ('viewed','discussed')").pluck(:id)
  end
end

module Exceptions
  class EventCountIncreasingTooFastError < ApiResponseError; end
end