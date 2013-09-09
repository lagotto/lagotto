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

require 'source_helper'
require 'timeout'

class SourceJob < Struct.new(:rs_ids, :source_id)
  include SourceHelper

  def enqueue(job)
    # keep track of when the article was queued up
    RetrievalStatus.update_all(["queued_at = ?", Time.zone.now], ["id in (?)", rs_ids] )
  end

  def perform

    source = Source.find(source_id)
    return 0 unless source.ready?

    Timeout.timeout(Delayed::Worker.max_run_time) do
      sleep_time = 0

      sleep(source.run_at - Time.zone.now) if source.disabled?

      rs_ids.each do | rs_id |
        rs = RetrievalStatus.find(rs_id)

        # Track API response result and duration in api_responses table
        response = { article_id: rs.article_id, source_id: rs.source_id, retrieval_status_id: rs_id }
        start_time = Time.zone.now
        ActiveSupport::Notifications.instrument("api_response.get") do |payload|
          response.merge!(perform_get_data(rs))
          payload.merge!(response)
        end

        if response[:event_count]
          # observe rate-limiting settings
          sleep_interval = start_time + source.job_interval - Time.zone.now
          sleep(sleep_interval) if sleep_interval > 0
        else
          # each time we fail to get an answer from a source, wait longer
          sleep(sleep_time += source.disable_delay)
        end
      end
    end

  end

  def perform_get_data(rs)

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
    # This mnethod returns a hash in the format { event_count: 12, previous_count: 8, retrieval_history_id: 3736, update_interval: 31 }
    # This hash can be used to track API responses, e.g. when event counts go down

    previous_count = rs.event_count
    update_interval = (Time.zone.now - rs.retrieved_at).to_i / 1.day

    data_from_source = rs.source.get_data(rs.article, { :retrieval_status => rs, :timeout => rs.source.timeout, :source_id => rs.source_id })
    if data_from_source.is_a?(Hash)
      events = data_from_source[:events]
      events_url = data_from_source[:events_url]
      event_count = data_from_source[:event_count]
      event_metrics = data_from_source[:event_metrics]
      attachment = data_from_source[:attachment]
    else
      # ERROR
      rs.update_attributes(:queued_at => nil)
      return { event_count: nil, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
    end

    retrieved_at = Time.zone.now

    # SKIPPED
    if event_count.nil?
      rs.update_attributes(:retrieved_at => retrieved_at,
                           :scheduled_at => rs.stale_at,
                           :queued_at => nil,
                           :event_count => 0)
      { event_count: 0, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
    else
      rh = RetrievalHistory.create(:retrieval_status_id => rs.id,
                                   :article_id => rs.article_id,
                                   :source_id => rs.source_id)
      # SUCCESS
      if event_count > 0
        data = { :doi => rs.article.doi,
                 :retrieved_at => retrieved_at,
                 :source => rs.source.name,
                 :events => events,
                 :events_url => events_url,
                 :event_metrics => event_metrics,
                 :doc_type => "current" }

        if attachment.present? && attachment[:filename].present? && attachment[:content_type].present? && attachment[:data].present?
          data[:_attachments] = {attachment[:filename] => {"content_type" => attachment[:content_type],
                                                           "data" => Base64.encode64(attachment[:data]).gsub(/\n/, '')}}
        end

        # save the data to mysql
        rs.event_count = event_count
        rs.event_metrics = event_metrics
        rs.events_url = events_url

        rh.event_count = event_count

        # save the data to couchdb
        rs_rev = save_alm_data("#{rs.source.name}:#{rs.article.doi_escaped}", data: data.clone, source_id: rs.source_id)

        data.delete(:_attachments)
        data[:doc_type] = "history"
        rh_rev = save_alm_data(rh.id, data: data, source_id: rs.source_id)

      # SUCCESS NO DATA
      else
        # save the data to mysql
        # don't save any data to couchdb
        rs.event_count = 0
        rh.event_count = 0
      end

      rs.retrieved_at = retrieved_at
      rs.scheduled_at = rs.stale_at
      rs.queued_at = nil
      rs.save

      rh.retrieved_at = retrieved_at
      rh.save

      { event_count: event_count, previous_count: previous_count, retrieval_history_id: rh.id, update_interval: update_interval }
    end
  end

  def error(job, e)
    source = Source.find(source_id)
    Alert.create(:exception => e, :message => "#{e.message} in #{job.queue}", :source_id => source.id)
  end

  def after(job)
    source = Source.find(source_id)
    source.stop_working unless source.get_queued_job_count > 1
  end

end
