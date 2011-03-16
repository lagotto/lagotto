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

class StripTagsTest < ActiveSupport::TestCase
  def test_strip_tags
    assert_equal "<article>This</article> <verb>is</verb> a <noun>test</noun>.".strip_tags,
                 "This is a test."
  end

  def test_strip_nested_tags
    assert_equal "<subject>This string</subject> <predicate>has <adjective>nested</adjective> tags.</predicate>".strip_tags,
                 "This string has nested tags."
  end

  def test_strip_without_tags
    assert_equal "This is a test".strip_tags,
                 "This is a test"
  end
end
