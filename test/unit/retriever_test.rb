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
require 'benchmark'

class RetrieverTest < ActiveSupport::TestCase
  def test_update_times_out
    Net::HTTP.expects(:new).returns(Sleepy.new(10))
    elapsed = Benchmark.realtime do
      assert_raise Retriever::RetrieverTimeout do
        Retriever.update_articles [articles(:not_stale)], nil, 1.seconds
      end
    end
    assert elapsed < 10
  end

  test "second article is sourced on timeout" do
    Net::HTTP.expects(:new).returns(Sleepy.new(10))
    article1 = articles(:not_stale)
    article2 = articles(:uncited_with_no_retrievals)
    article2.expects(:citations_count).never
    elapsed = Benchmark.realtime do
      assert_raise Retriever::RetrieverTimeout do
        Retriever.update_articles [article1, article2], nil, 1.seconds
      end
    end
    assert elapsed < 10
  end

  test "source timeout should not cause rake timeout" do
    crossref = sources(:crossref)
    crossref.timeout = 1
    crossref.save!

    resp = Net::HTTPOK.new('1.1', '200', '')
    resp.expects(:body).at_least_once.returns('')
    Net::HTTP.expects(:new).at_least_once.returns(Sleepy.new(2, resp))
    article1 = articles(:not_stale)
    article2 = articles(:uncited_with_no_retrievals)
    article2.expects(:citations_count).at_least_once
    Retriever.update_articles [article1, article2]
    assert crossref.reload.disable_until.present?
  end
end

class Sleepy
  def initialize seconds, returns = nil
    @seconds = seconds
    @returns = returns
  end

  def method_missing *args
    sleep @seconds
    return @returns unless @returns.nil?
    raise Overslept.new
  end

  class Overslept < Exception; end
end