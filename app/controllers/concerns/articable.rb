# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

module Articable
  extend ActiveSupport::Concern

  included do
    def index
      # Filter by source parameter, filter out private sources unless admin
      # Load articles from ids listed in query string, use type parameter if present
      # Translate type query parameter into column name
      # Paginate query results (50 per page)
      source_ids = get_source_ids(params[:source])
      collection = ArticleDecorator.includes(:retrieval_statuses).where(:retrieval_statuses => { :source_id => source_ids })

      if params[:ids]
        type = ["doi", "pmid", "pmcid", "mendeley_uuid"].find { |t| t == params[:type] } || Article.uid
        ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }
        collection = collection.where(:articles => { type.to_sym => ids })
      elsif params[:q]
        collection = collection.query(params[:q])
      end

      if params[:class_name]
        @class_name = params[:class_name]
        collection = collection.includes(:alerts)
        if @class_name == "All Alerts"
          collection = collection.where("alerts.unresolved = ?", true)
        else
          collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
        end
      end

      collection = collection.order_articles(params[:order])
      collection = collection.paginate(:page => params[:page])
      @articles = collection.decorate(:context => { :info => params[:info], :source => params[:source] })
    end
  end
end
