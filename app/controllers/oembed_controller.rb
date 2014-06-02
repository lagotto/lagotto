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

class OembedController < ApplicationController
  respond_to :json, :xml

  def show
    id_hash = Article.from_uri(params[:url])
    @article = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).first.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })

    # Return 404 HTTP status code and error message if article wasn't found
    render "404", :status => 404 if @article.blank?
  end
end
