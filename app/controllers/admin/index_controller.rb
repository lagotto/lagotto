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
    @articles_recent_count = Article.where("TIMESTAMPDIFF(DAY, published_on, UTC_TIMESTAMP()) <= 30").count
    
    @sources = Source.order("name")
    @sources_inactive_count = Source.where("active != 1").count
    @sources_disabled_count = Source.where("disable_until IS NOT NULL").count
    @groups = Group.order("name")
    @delayed_jobs = DelayedJob.order("queue, run_at DESC")
    @delayed_jobs_errors_count = DelayedJob.where("failed_at IS NOT NULL").count
  end
end