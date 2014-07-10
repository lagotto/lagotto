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
  before_filter :load_article, :only => [ :show, :edit, :update, :destroy ]
  before_filter :new_article, :only => [:create]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    @page = params[:page] || 1
    @q = params[:q]
    @class_name = params[:class_name]
    @order = params[:order]

    respond_with do |format|
      format.js { render "index" }
    end
  end

  def show
    format_options = params.slice :events, :source

    @groups = Group.order("id")
    @api_key = CONFIG[:api_key]

    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # GET /articles/new
  def new
    @article = Article.new(day: Date.today.day, month: Date.today.month, year: Date.today.year)
    respond_with(@article) do |format|
      format.js { render :index }
    end
  end

  # POST /articles
  def create
    @article.save
    respond_with(@article) do |format|
      format.js { render :index }
    end
  end

  # GET /articles/:id/edit
  def edit
    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # PUT /articles/:id(.:format)
  def update
    @article.update_attributes(safe_params)
    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # DELETE /articles/:id(.:format)
  def destroy
    @article.destroy
    redirect_to articles_path
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

    # raise error if article wasn't found
    fail ActiveRecord::RecordNotFound if @article.blank?
  end

  def new_article
    @article = Article.new(safe_params)
  end

  private

  def safe_params
    params.require(:article).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
  end
end

