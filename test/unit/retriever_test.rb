require 'test_helper'
require 'benchmark'

class RetrieverTest < ActiveSupport::TestCase
  def test_update_times_out
    Net::HTTP::Get.expects(:new).returns(Sleepy.new(10))
    elapsed = Benchmark.realtime do
      assert_raise Timeout::Error do
        Retriever.update_articles [articles(:not_stale)], nil, 1.seconds
      end
    end
    assert elapsed < 10
  end

  test "second article is sourced on timeout" do
    Net::HTTP::Get.expects(:new).returns(Sleepy.new(10))
    article1 = articles(:not_stale)
    article2 = articles(:uncited_with_no_retrievals)
    article2.expects(:citations_count).never
    elapsed = Benchmark.realtime do
      assert_raise Timeout::Error do
        Retriever.update_articles [article1, article2], nil, 1.seconds
      end
    end
    assert elapsed < 10
  end
end

class Sleepy
  def initialize seconds
    @seconds = seconds
  end

  def method_missing *args
    sleep @seconds
    raise Overslept.new
  end

  class Overslept < Exception; end
end