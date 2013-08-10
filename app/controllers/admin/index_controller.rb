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

    @sources_count = Source.count
    @sources_inactive_count = Source.where("active != 1").count
    @sources_disabled_count = Source.where("disable_until IS NOT NULL").count
    @delayed_jobs_active_count = DelayedJob.count
    @delayed_jobs_count = RetrievalStatus.total(1).count
    @delayed_jobs_errors_count = ErrorMessage.unscoped.from_sources(1).count
    @queued_count = RetrievalStatus.queued.count
    @error_messages_count = ErrorMessage.unscoped.count
    @error_messages_last_day_count = ErrorMessage.total(1).count
    @requests_count = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").count
    @requests_page_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:page_duration)
    @users_count = User.count
    @api_users_count = User.where(:role => "user").count
    @couchdb_info = RetrievalHistory.new.get_alm_database || { "doc_count" => 0, "disk_size" => 0 }
    @mysql_info = RetrievalHistory.table_status

    render :index
  end
end
