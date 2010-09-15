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

class UnconfiguredSource < Source
end

class SourcesControllerTest < ActionController::TestCase
  def setup
    login_as(:quentin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end

  def test_should_get_new
    get :new, :class => "UnconfiguredSource"
    assert_response :success
  end

  def test_should_create_source
    assert_difference('Source.count') do
      post :create, :source => {}, :class => "UnconfiguredSource"
    end

    assert_redirected_to sources_path
  end

  def test_should_show_source
    get :show, :id => sources(:crossref).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => sources(:crossref).id
    assert_response :success
  end

  def test_should_update_source
    put :update, :id => sources(:crossref).id, 
                 :source => { :class => sources(:crossref).class.name }
    assert_redirected_to sources_path
  end

  def test_should_destroy_source
    assert_difference('Source.count', -1) do
      delete :destroy, :id => sources(:crossref).id
    end

    assert_redirected_to sources_path
  end
end
