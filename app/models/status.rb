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

class Status
  attr_reader :articles_count, :events_count, :sources_disabled_count, :alerts_last_day_count, :workers_count, :delayed_jobs_active_count, :responses_count, :requests_count, :users_count, :version, :couchdb_size, :mysql_size, :update_date, :cache_key

  def articles_count
    Article.count
  end

  def articles_last30_count
    Article.last_x_days(30).count
  end

  def events_count
    RetrievalStatus.joins(:source).where("state > ?", 0).where("name != ?", "relativemetric").sum(:event_count)
  end

  def alerts_last_day_count
    Alert.total_errors(1).count
  end

  def workers_count
    if CONFIG[:workers] > 0
      Worker.count
    else
      0
    end
  end

  def delayed_jobs_active_count
    DelayedJob.count
  end

  def responses_count
    ApiResponse.total(1).count
  end

  def requests_count
    ApiRequest.where("created_at > ?", Time.zone.now - 1.day).count
  end

  def users_count
    User.count
  end

  def sources_active_count
    Source.active.count
  end

  def version
    Rails.application.config.version
  end

  def couchdb_size
    RetrievalStatus.new.get_alm_database["disk_size"] || 0
  end

  def update_date
    Rails.cache.fetch('status:timestamp') { Time.zone.now.utc.iso8601 }
  end

  alias_method :cache_key, :update_date
end
