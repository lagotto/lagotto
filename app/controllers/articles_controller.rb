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

class ArticlesController < ApplicationController

  respond_to :html, :xml, :json

  # GET /articles
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to published_on desc)
    # source=source_type

    collection = Article
    collection = collection.cited(params[:cited]) if params[:cited]
    collection = collection.query(params[:query]) if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.includes(:retrieval_statuses).paginate(:page => params[:page])

    # if private sources have been filtered out, the source parameter will be present and modified

    # source url parameter is only used for csv format
    @source = Source.find_by_name(params[:source].downcase) if params[:source]

    if params[:source]
      @sources = Source.where("lower(name) in (?)", params[:source].split(",")).order("name")
    else
      @sources = Source.order("name")
    end

    respond_with(@articles) do |format|
      format.json { render :json => @articles, :callback => params[:callback] }
      format.csv  { render :csv => @articles }
    end
  end

  # GET /articles/:id
  def show

    load_article

    format_options = params.slice :events, :history, :source

    @groups = Group.order("id")
    @api_key = APP_CONFIG['api_key']

    # if private sources have been filtered out, the source parameter will be present and modified
    # private sources are filtered out in the load_article_eager_includes method by looking at source parameter
    load_article_eager_includes

    # if private sources have been filtered out, the source parameter will be present and modified
    # private sources are filtered out in the load_article_eager_includes method by looking at source parameter
    load_article_eager_includes

    respond_with(@article) do |format|
      format.csv  { render :csv => @article }
      format.json { render :json => @article.as_json(format_options), :callback => params[:callback] }
      format.xml  do
        response.headers['Content-Disposition'] = 'attachment; filename=' + params[:id].sub(/^info:/,'') + '.xml'
        render :xml => @article.to_xml(:events => format_options[:events],
                                       :history => format_options[:history],
                                       :source => format_options[:source])
      end
    end
  end

  protected
  def load_article()
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first
  end

  def load_article_eager_includes
    id_hash = Article.from_uri(params[:id])
    if params[:source]
      @article = Article.where("#{id_hash.keys.first} = ? and lower(sources.name) in (?)", id_hash.values.first, params[:source].downcase.split(",")).
        includes(:retrieval_statuses => :source).first
    else
      @article = Article.where(id_hash).includes(:retrieval_statuses => :source).first
    end

    # raise error if article wasn't found
    raise ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @article.blank?
  end

end
