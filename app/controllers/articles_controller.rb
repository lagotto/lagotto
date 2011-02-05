# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
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
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :load_article, 
                :only => [ :edit, :update, :destroy ]

  # GET /articles
  # GET /articles.xml
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to doi)
    # source=source_type
    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order(params[:order])  if params[:order]

    @articles = collection.paginate :page => params[:page], :per_page => params[:per_page], :include => :retrievals
    @source = Source.find_by_type(params[:source]) if params[:source]

    respond_to do |format|
      format.html
      format.xml  { render :xml => @articles }
      format.json { render :json => @articles, :callback => params[:callback] }
      format.csv  { render :csv => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    if params[:refresh] == "now"
      load_article
      Retriever.new(:lazy => false, :only_source => false).update(@article)      
      redirect_to(@article) and return  # why not just keep going with show?
    end

    load_article(eager_includes)
    format_options = params.slice :citations, :history, :source

    if params[:refresh] == "soon" or @article.stale?
      uid = RetrievalWorker.async_retrieval(:article_id => @article.id)
      logger.info "Queuing article #{@article.id} for retrieval as #{uid}"
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml do
        response.headers['Content-Disposition'] = 'attachment; filename=' + params[:id].sub(/^info:/,'') + '.xml'
        render :xml => @article.to_xml(format_options)
      end
      format.csv  { render :csv => @article }
      format.json { render :json => @article.to_json(format_options), :callback => params[:callback] }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
      format.json { render :json => @article }
    end
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'

        Source.all.each do |source|
          Retrieval.find_or_create_by_article_id_and_source_id(@article.id, source.id)
        end    

        format.html { redirect_to(@article) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
        format.json { render :json => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to(@article) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

protected
  def load_article(options={})
    # Load one article given query params, for the non-#index actions
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi, options)
  end

  def eager_includes
    returning :include => { :retrievals => [ :source ] } do |r|
      r[:include][:retrievals] << :citations if params[:citations] == "1"
      r[:include][:retrievals] << :histories if params[:history] == "1"
      r[:conditions] = ['LOWER(sources.type) IN (?)', params[:source].downcase.split(",")] if params[:source]
    end
  end
end
