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

require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  def test_articles
    get :groupArticleSummaries, :id => articles(:not_stale).doi
    assert_response :success
  end

  def test_articles_xml
    get :groupArticleSummaries, :id => articles(:not_stale).doi, :format => 'xml'
    assert_response :success
  end

  def test_articles_json
    get :groupArticleSummaries, :id => articles(:not_stale).doi, :format => 'json'
    assert_response :success
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal groups(:cool_kids).name.downcase, json[0]['groupcounts'][0]['name']
  end

  def test_articles_jsonp
    get :groupArticleSummaries, :id => articles(:not_stale).doi, :format => 'json', :callback => 'foo'
    assert_response :success
    assert @response.body.start_with?('foo(')
  end
end
