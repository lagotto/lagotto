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

class DoiTest < ActiveSupport::TestCase
  def setup
    @doi = "10.0/dummy"
    @doi_uri = "info:doi/#{@doi}"
    @doi_url = "http://dx.doi.org/#{@doi}"
  end

  def test_should_convert_from_uri
    assert_equal DOI::from_uri(@doi), @doi
    assert_equal DOI::from_uri(@doi_uri), @doi
    assert_equal DOI::from_uri(@doi_url), @doi
    assert_nil DOI::from_uri(nil)
  end

  def test_should_convert_to_uri
    assert_equal DOI::to_uri(@doi), @doi_uri
    assert_equal DOI::to_uri(@doi_uri), @doi_uri
    assert_equal DOI::to_uri(@doi_url), @doi_uri
    assert_nil DOI::to_uri(nil)
  end

  def test_should_convert_to_url
    assert_equal DOI::to_url(@doi), @doi_url
  end
end
