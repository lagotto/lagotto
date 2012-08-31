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

require 'doi'

class GroupsController < ApplicationController

  respond_to :html

  def group_article_summaries

    if !params[:id]
      raise "ID parameter not specified"
    end

    # get the list of DOIs
    ids = params[:id].split(",")
    ids = ids.map { |id| DOI::from_uri(id) }

    # get all the groups
    groups = {}
    gs = Group.all
    gs.each { |group| groups[group.id] = group.name }

    @summaries = []

    # get the articles
    if params[:source]
      articles = Article.where("doi in (?) and lower(sources.name) in (?)", ids, params[:source].downcase.split(",")).
          includes( :retrieval_statuses => { :source => :group })
    else
      articles = Article.where("doi in (?)", ids).includes( :retrieval_statuses => { :source => :group })
    end

    articles.each do |article|
      summary = {}

      summary[:article] = article

      # for each article, group the source information by group
      group_info = article.group_source_info

      summary[:groupcounts] = []
      group_info.each do |key, value|
        total = value.inject(0) {|sum, source| sum + source[:count] }
        summary[:groupcounts] << {:name => groups[key],
                                  :count => total,
                                  :sources => value}
      end

      # if any groups are specified via URL params, get data for each source that belongs to the given group
      summary[:groups] = params[:group].split(",").map do |group_name|
        group = Group.where("lower(name) = lower(?)", group_name).first
        if not group.nil?
          sources = article.get_data_by_group(group)
          { :name => group.name,
            :sources => sources } unless sources.empty?
        end
      end.compact if params[:group]

      @summaries << summary
    end

    respond_with(@summaries) do |format|
      format.html
      format.json { render :json => @summaries, :callback => params[:callback]}
      format.xml { render :xml => @summaries }
    end
  end
end
