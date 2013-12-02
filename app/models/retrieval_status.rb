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

class RetrievalStatus < ActiveRecord::Base

  belongs_to :article, :touch => true
  belongs_to :source
  has_many :retrieval_histories, :dependent => :destroy

  serialize :event_metrics

  delegate :name, :to => :source
  delegate :display_name, :to => :source

  scope :most_cited, lambda { where("event_count > 0").order("event_count desc").limit(25) }
  scope :most_cited_last_x_days, lambda { |days| joins(:article).where("event_count > 0 AND articles.published_on >= CURDATE() - INTERVAL ? DAY", days).order("event_count desc").limit(25) }
  scope :most_cited_last_x_months, lambda { |months| joins(:article).where("event_count > 0 AND articles.published_on >= CURDATE() - INTERVAL ? MONTH", months).order("event_count desc").limit(25) }

  scope :queued, where("queued_at is NOT NULL")
  scope :not_queued, where("queued_at is NULL")
  scope :stale, where("queued_at is NULL AND scheduled_at IS NOT NULL AND scheduled_at <= NOW()").order("scheduled_at")
  scope :published, joins(:article).where("queued_at is NULL AND articles.published_on <= CURDATE()")
  scope :with_sources, joins(:source).where("sources.state > 0").order("group_id, display_name")

  scope :total, lambda { |days| where("retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :with_events, lambda { |days| where("event_count > 0 AND retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :without_events, lambda { |days| where("event_count = 0 AND retrieved_at > NOW() - INTERVAL ? DAY", days) }

  scope :by_source, lambda { |source_ids| where(:source_id => source_ids) }

  def data
    if event_count > 0
      data = get_alm_data("#{source.name}:#{article.doi_escaped}")
    else
      nil
    end
  end

  def events
    unless data.blank?
      data["events"]
    else
      []
    end
  end

  def metrics
    unless data.blank?
      data["event_metrics"]
    else
      []
    end
  end

  def delete_document
    unless data_rev.nil
      document_id = "#{source.name}:#{article.uid_escaped}"
      remove_alm_data(document_id, data_rev)
    else
      nil
    end
  end

  # calculate datetime when retrieval_status should be updated, adding random interval
  def stale_at
    unless article.published_on.nil?
      age_in_days = Time.zone.today - article.published_on
    else
      age_in_days = 366
    end

    if age_in_days < 0
      article.published_on
    elsif (0..7) === age_in_days
      random_time(source.staleness[0])
    elsif (8..31) === age_in_days
      random_time(source.staleness[1])
    elsif (32..365) === age_in_days
      random_time(source.staleness[2])
    else
      random_time(source.staleness.last)
    end
  end

  def random_time(duration)
    Time.zone.now + duration + rand(duration/10)
  end

end
