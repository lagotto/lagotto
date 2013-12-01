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

class SourceDecorator < Draper::Decorator
  delegate_all

  def state
    human_state_name
  end

  def group
    group_id
  end

  def jobs
    { "queueing" => model.get_queueing_job_count,
      "working" => model.delayed_jobs.count(:locked_at),
      "pending" => model.delayed_jobs.count - model.delayed_jobs.count(:locked_at) }
  end

  def responses
    { "count" => model.api_responses.total(1).size,
      "average" => model.api_responses.total(1).average("duration").nil? ? 0 : model.api_responses.total(1).average("duration").to_i,
      "maximum" => model.api_responses.total(1).maximum("duration").nil? ? 0 : model.api_responses.total(1).maximum("duration").to_i }
  end

  def error_count
    model.alerts.total_errors(1).size
  end

  def article_count
    model.articles.cited(1).size
  end

  def event_count
    model.retrieval_statuses.sum(:event_count)
  end

  def status
    { "refreshed" => Article.count - (model.retrieval_statuses.stale.size + model.retrieval_statuses.queued.size),
      "queued" => model.retrieval_statuses.queued.size,
      "stale" => model.retrieval_statuses.stale.size }
  end

  def by_day
    { "with_events" => model.retrieval_statuses.with_events(1).size,
      "without_events" => model.retrieval_statuses.without_events(1).size,
      "not_updated" => Article.count - (model.retrieval_statuses.with_events(1).size + model.retrieval_statuses.without_events(1).size) }
  end

  def by_month
    { "with_events" => model.retrieval_statuses.with_events(31).size,
      "without_events" => model.retrieval_statuses.without_events(31).size,
      "not_updated" => Article.count - (model.retrieval_statuses.with_events(31).size + model.retrieval_statuses.without_events(31).size) }
  end

  def cache_key
    "#{name}/#{cached_at.to_s(:number)}"
  end

  def update_date
    cached_at.utc.iso8601
  end

end
