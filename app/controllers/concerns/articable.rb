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
      # Load articles from ids listed in query string, use type parameter if present
      # Translate type query parameter into column name
      # Paginate query results (50 per page)
      collection = ArticleDecorator.preload(:retrieval_statuses).includes(:sources)

      if params[:ids]
        type = ["doi", "pmid", "pmcid", "mendeley_uuid"].find { |t| t == params[:type] } || Article.uid
        ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }
        collection = collection.where(:articles => { type.to_sym => ids })
      elsif params[:q]
        collection = collection.query(params[:q])
      end

      if params[:class_name]
        @class_name = params[:class_name]
        collection = collection.preload(:alerts)
        if @class_name == "All Alerts"
          collection = collection.where("alerts.unresolved = ?", true)
        else
          collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
        end
      end

      if params[:order] && source = Source.find_by_name(params[:order])
        collection = collection.joins(:retrieval_statuses)
          .where("retrieval_statuses.source_id = ?", source.id)
          .where("retrieval_statuses.event_count > 0")
          .order("retrieval_statuses.event_count DESC")
      else
        collection = collection.order("published_on DESC")
      end

      collection = collection.page(params[:page])
      collection = collection.per_page(params[:rows].to_i) if params[:rows] && (1..50).include?(params[:rows].to_i)
      @articles = collection.decorate(:context => { :info => params[:info], :source => params[:source] })
    end

    protected

    def load_article
      # Load one article given query params
      id_hash = Article.from_uri(params[:id])
      if id_hash.respond_to?("key")
        key, value = id_hash.first
        @article = Article.where(key => value).first
      else
        @article = nil
      end
    end

    private

    def safe_params
      params.require(:article).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
    end
  end
end
