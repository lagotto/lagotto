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
    Rails.logger.debug "enqueue #{rs_ids.inspect}"

    # keep track of when the article was queued up
    RetrievalStatus.update_all(["queued_at = ?", Time.zone.now], ["id in (?)", rs_ids] )
  end

  def perform

    # check to see if source is active or not
    source = Source.find(source_id)
    unless source.active
      Rails.logger.info "#{source.name} not active. Exiting the job"
      return
    end

    srand
    #time to sleep between failures
    sleep_time = 0

    # just in case a worker gets stuck
    Timeout.timeout(Delayed::Worker.max_run_time) do
      # wait till the source isn't disabled
      while not (source.disable_until.nil? || source.disable_until < Time.zone.now)
        Rails.logger.info "#{source.name} is disabled. Sleep for #{source.disable_delay} seconds."
        sleep(source.disable_delay)
      end

      rs_ids.each do | rs_id |
        unless perform_get_data(rs_id)
          # each time we fail to get an answer from a source, wait longer
          # and wait random amount of time
          sleep_time += source.disable_delay + rand(source.disable_delay)
          Rails.logger.info "Sleep for #{sleep_time} seconds"
          sleep(sleep_time)
        end
      end
    end

  end

  def perform_get_data(rs_id)

    rs = RetrievalStatus.find(rs_id)

    Rails.logger.debug "#{rs.source.name} #{rs.article.doi} perform"

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
    # so that the request is repeated later. We could get stuck, but we see this in error_messages

    data_from_source = rs.source.get_data(rs.article, { :retrieval_status => rs, :timeout => rs.source.timeout, :source_id => rs.source_id })
    if data_from_source.is_a?(Hash)
      events = data_from_source[:events]
      events_url = data_from_source[:events_url]
      event_count = data_from_source[:event_count]
      event_metrics = data_from_source[:event_metrics]
      attachment = data_from_source[:attachment]
    else
      # ERROR
      return nil
    end

    retrieved_at = Time.zone.now

    # SKIPPED
    if event_count.nil?
      rs.update_attributes(:retrieved_at => retrieved_at,
                           :scheduled_at => rs.stale_at,
                           :event_count => 0)
      { :retrieval_status => rs }
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

        if !attachment.nil?

          if !attachment[:filename].nil? && !attachment[:content_type].nil? && !attachment[:data].nil?
            data[:_attachments] = {attachment[:filename] => {"content_type" => attachment[:content_type],
                                                             "data" => Base64.encode64(attachment[:data]).gsub(/\n/, '')}}
          end
        end

        # save the data to couchdb
        rs_rev = save_alm_data("#{rs.source.name}:#{rs.article.doi_escaped}", data: data.clone, source_id: rs.source_id)
        rs.event_count = event_count
        rs.event_metrics = event_metrics
        rs.events_url = events_url

        # save the history data to couchdb
        data.delete(:_attachments)
        data[:doc_type] = "history"
        rh_rev = save_alm_data(rh.id, data: data, source_id: rs.source_id)

        # set retrieval history status to success
        rh.status = RetrievalHistory::SUCCESS_MSG
        # save the event count in mysql
        rh.event_count = event_count

      # SUCCESS NO DATA
      else
        # if we don't get any data
        rs.event_count = 0

        # don't save any data to CouchDB

        # set retrieval history status to success with no data
        rh.status = RetrievalHistory::SUCCESS_NODATA_MSG
        rh.event_count = 0
      end

      rs.retrieved_at = retrieved_at
      rs.scheduled_at = rs.stale_at
      rs.save

      rh.retrieved_at = retrieved_at
      rh.save
      { :retrieval_status => rs, :retrieval_history => rh }
    end
  end

  def error(job, e)
    source_id = Source.where(:name => job.queue).pluck(:id).first
    ErrorMessage.create(:exception => e, :message => "#{e.message} in #{job.queue}", :source_id => source_id)
  end

  def after(job)
    Rails.logger.debug "job completed"

    #reset the queued at value
    RetrievalStatus.update_all(["queued_at = ?", nil], ["id in (?)", rs_ids] )
  end

end

