require 'test_helper'
require 'benchmark'

class RetrieverTest < ActiveSupport::TestCase
  def test_update_times_out
    article = Sleepy.new 10
    elapsed = Benchmark.realtime do
      assert_raise Timeout::Error do
        Retriever.update_articles [article], nil, 1.seconds
      end
    end
    assert elapsed < 10
  end

  test "second article is sourced on timeout" do
    article1 = Sleepy.new 10
    article2 = mock()
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