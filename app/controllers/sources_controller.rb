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

class SourcesController < ApplicationController
  before_filter :load_source, :only => [ :show, :edit, :update ]
  load_and_authorize_resource

  respond_to :html, :rss

  def show
    @source = Source.find_by_name(params[:id])

    # raise error if source wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?

    @doc = Doc.find(@source.name)

    respond_with(@source) do |format|
      format.rss do
        if params[:days]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_days(params[:days].to_i)
        elsif params[:months]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_months(params[:months].to_i)
        else
          @retrieval_statuses = @source.retrieval_statuses.most_cited
        end
        render :show
      end
    end
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

   def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  def update
    params[:source] ||= {}
    params[:source][:state_event] = params[:state_event] if params[:state_event]
    @source.update_attributes(safe_params)
    if @source.invalid?
      error_messages = @source.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure source #{@source.display_name}: #{error_messages}"
      @flash = flash
    end
    respond_with(@source) do |format|
      if params[:state_event]
        @groups = Group.includes(:sources).order("groups.id, sources.display_name")
        format.js { render :index }
      else
        format.js { render :show }
      end
    end
  end

  protected

  def load_source
    @source = Source.find_by_name(params[:id])
  end

  private

  def safe_params
    params.require(:source).permit(:display_name,
                                   :group_id,
                                   :state_event,
                                   :private,
                                   :queueable,
                                   :description,
                                   :job_batch_size,
                                   :workers,
                                   :rate_limiting,
                                   :wait_time,
                                   :staleness_week,
                                   :staleness_month,
                                   :staleness_year,
                                   :staleness_all,
                                   :cron_line,
                                   :timeout,
                                   :max_failed_queries,
                                   :max_failed_query_time_interval,
                                   :disable_delay,
                                   :url,
                                   :url_with_type,
                                   :url_with_title,
                                   :related_articles_url,
                                   :api_key,
                                   *@source.config_fields)
  end
end
