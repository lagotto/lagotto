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

  respond_to :html

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

    if params[:source]
      @sources = Source.where("lower(name) in (?)", params[:source].split(",")).order("name")
    else
      @sources = Source.order("name")
    end

    respond_with(@articles)
  end

  # GET /articles/:id
  def show

    load_article

    format_options = params.slice :events, :history, :source

    @groups = Group.order("id")
    @api_key = APP_CONFIG['api_key']

    respond_with(@article)
  end

  protected
  def load_article()
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first

    # raise error if article wasn't found
    raise ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @article.blank?
  end
end
