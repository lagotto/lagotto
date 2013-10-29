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

  respond_to :html, :rss

  def show
    @source = Source.find_by_name(params[:id])

    # raise error if source wasn't found
    raise ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?

    filename = Rails.root.join("docs/#{@source.name.capitalize}.md")
    @doc = { :text => File.exist?(filename) ? IO.read(filename) : "No documentation found." }

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
    @groups = Group.order("id")
    respond_with @groups
  end

end
