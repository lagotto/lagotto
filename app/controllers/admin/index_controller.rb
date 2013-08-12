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

class Admin::IndexController < Admin::ApplicationController

  load_and_authorize_resource :error_message, :parent => false

  def index
    @articles_count = Article.count
    @articles_recent_count = Article.last_x_days(30).count
    @sources_disabled_count = Source.where("disable_until IS NOT NULL").count
    @error_messages_last_day_count = ErrorMessage.total(1).count
    @events_count = RetrievalStatus.joins(:source).where("active = 1 AND name != 'relativemetric'").sum(:event_count)
    @queued_count = RetrievalStatus.queued.count
    @delayed_jobs_active_count = DelayedJob.count
    @delayed_jobs_count = RetrievalStatus.total(1).count
    @requests_count = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").count
    @users_count = User.count
    @couchdb_info = RetrievalHistory.new.get_alm_database || { "doc_count" => 0, "disk_size" => 0 }
    @mysql_info = RetrievalHistory.table_status

    render :index
  end
end
