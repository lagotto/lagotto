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

module Performable
  extend ActiveSupport::Concern

  included do

    def perform_get_data
      # we can get data_from_source in 4 different formats
      # - hash with event_count nil: SKIPPED
      # - hash with event_count = 0: SUCCESS NO DATA
      # - hash with event_count > 0: SUCCESS
      # - nil                      : ERROR
      #
      # SKIPPED
      # The source doesn't know about the article identifier, and we never call the API.
      # Examples: mendeley, pub_med, counter, copernicus
      # We don't want to create a retrieval_history record, but should update retrieval_status
      #
      # SUCCESS NO DATA
      # The source knows about the article identifier, but returns an event_count of 0
      #
      # SUCCESS
      # The source knows about the article identifier, and returns an event_count > 0
      #
      # ERROR
      # An error occured, typically 408 (Request Timeout), 403 (Too Many Requests) or 401 (Unauthorized)
      # It could also be an error in our code. 404 (Not Found) errors are handled as SUCCESS NO DATA
      # We don't update retrieval status and don't create a retrieval_histories document,
      # so that the request is repeated later. We could get stuck, but we see this in alerts
      #
      # This method returns a hash in the format event_count: 12, previous_count: 8, retrieval_history_id: 3736, update_interval: 31
      # This hash can be used to track API responses, e.g. when event counts go down

      previous_count = event_count
      if [Date.new(1970, 1, 1), Date.today].include?(retrieved_at.to_date)
        update_interval = 1
      else
        update_interval = (Date.today - retrieved_at.to_date).to_i
      end

      result = source.get_data(article, timeout: source.timeout, source_id: source_id)
      data_from_source = source.parse_data(result, article, source_id: source_id)
      if data_from_source[:error]
        return { event_count: nil, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
      else
        events = data_from_source[:events]
        events_url = data_from_source[:events_url]
        event_count = data_from_source[:event_count]
        event_metrics = data_from_source[:event_metrics]
      end

      retrieved_at = Time.zone.now

      # SKIPPED
      if event_count.nil?
        update_attributes(:retrieved_at => retrieved_at,
                          :scheduled_at => stale_at,
                          :event_count => 0)
        { event_count: 0, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
      else
        rh = RetrievalHistory.create(:retrieval_status_id => id,
                                     :article_id => article_id,
                                     :source_id => source_id)
        # SUCCESS
        if event_count > 0
          data = { CONFIG[:uid].to_sym => article.uid,
                   :retrieved_at => retrieved_at,
                   :source => source.name,
                   :events => events,
                   :events_url => events_url,
                   :event_metrics => event_metrics,
                   :doc_type => "current" }

          # save the data to mysql
          event_count = event_count
          event_metrics = event_metrics
          events_url = events_url

          rh.event_count = event_count

          # save the data to couchdb
          rs_rev = save_alm_data("#{source.name}:#{article.uid_escaped}", data: data.clone, source_id: source_id)

          data[:doc_type] = "history"
          rh_rev = save_alm_data(rh.id, data: data, source_id: source_id)

        # SUCCESS NO DATA
        else
          # save the data to mysql
          # don't save any data to couchdb
          event_count = 0
          rh.event_count = 0
        end

        retrieved_at = retrieved_at
        scheduled_at = stale_at
        save

        rh.retrieved_at = retrieved_at
        rh.save

        { event_count: event_count, previous_count: previous_count, retrieval_history_id: rh.id, update_interval: update_interval }
      end
    end
  end
end
