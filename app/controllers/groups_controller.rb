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

class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show, :articles ]

  #This is a way of excepting a list of DOIS and getting back summaries for them all.
  #Articles with no cites are not returned
  #This method does not check for article staleness and does not query articles for refresh
  def groupArticleSummaries
    logger.debug "groupArticleSummaries"

    #Here we have to get format in a different manner 
    #Specifying multilple DOIS without a parameter proved nightmareish
    #So we do it here using a comma delimated list with format 
    #Specified as a parameter
    reqFormat = params[:format]

    if reqFormat == nil or reqFormat == "" or reqFormat == "xml" or reqFormat == "csv" or reqFormat == "json"
      request.format = reqFormat
    else
      raise "Bad response format requested:'" + reqFormat + "' valid values are 'xml','csv' or 'json'"
    end

    if !params[:id]
      raise "ID parameter not specified"
    end

    #Ids can be a collection
    ids = params[:id].split(',')
    ids = ids.map { |id| DOI::from_uri(id) }
      
    @result  = []

    # Specifiy the eager loading so we get all the data we need up front
    articles = Article.find(:all, 
      :include => [ :retrievals => [ :citations, { :source => :group } ]], 
      :conditions => [ "articles.doi in (?) and (retrievals.citations_count > 0 or retrievals.other_citations_count > 0)", ids ])
    
    @result = articles.map do |article|
      returning Hash.new do |hash|
        hash[:article] = article
        hash[:groupcounts] = article.citations_by_group
        
        # If any groups are specified via URL params, get those details
        hash[:groups] = params[:group].split(",").map do |group|
          sources = article.get_cites_by_group(group)
          { :name => group,
            :sources => sources } unless sources.empty?
        end.compact if params[:group]
      end
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @result }
      format.json { render :json => @result, :callback => params[:callback] }
    end
  end

  # GET /groups
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /groups/1
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(groups_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # POST /groups/1
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(groups_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /groups/1
  def destroy
    @group = Group.find(params[:id])
    
    Source.find(:all, :conditions => {  :group_id => @group.id }).each do |s| 
      s.group = nil;
      s.save
    end
    
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
    end
  end

end

