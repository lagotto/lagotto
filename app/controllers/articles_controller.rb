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

  def index
    @page = params[:page] || 1
    @q = params[:q]
    @class_name = params[:class_name]
    @order = params[:order]
  end

  def show
    load_article

    format_options = params.slice :events, :source

    @groups = Group.order("id")

    respond_with(@article)
  end

  protected

  def load_article
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @article = Article.includes(:source).where(key => value).first
    else
      @article = nil
    end

     # raise error if article wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @article.blank?
  end
end
