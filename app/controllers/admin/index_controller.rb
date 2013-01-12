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
  
  def index
    @articles_count = Article.count
    @articles_recent_count = Article.last_x_days(30).count
    
    @sources_count = Source.count
    @sources_inactive_count = Source.where("active != 1").count
    @sources_disabled_count = Source.where("disable_until IS NOT NULL").count
    @delayed_jobs_active_count = DelayedJob.count
    @delayed_jobs_count = RetrievalHistory.total(1).count
    @delayed_jobs_errors_count = RetrievalHistory.with_errors(1).count
    @queued_count = RetrievalStatus.queued.count
    @error_messages_count = ErrorMessage.unscoped.count
    @error_messages_last_day_count = ErrorMessage.total(1).count
    @couchdb_info = Source.new.get_alm_database
  end
end