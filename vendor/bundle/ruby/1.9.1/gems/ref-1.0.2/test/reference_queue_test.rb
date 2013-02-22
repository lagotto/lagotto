require File.expand_path("../test_helper", __FILE__)

class TestReferenceQueue < Test::Unit::TestCase
  def test_can_add_references
    queue = Ref::ReferenceQueue.new
    ref_1 = Ref::WeakReference.new(Object.new)
    ref_2 = Ref::WeakReference.new(Object.new)
    assert queue.empty?
    assert_equal 0, queue.size
    queue.push(ref_1)
    queue.push(ref_2)
    assert !queue.empty?
    assert_equal 2, queue.size
  end
  
  def test_can_remove_references_as_a_queue
    queue = Ref::ReferenceQueue.new
    ref_1 = Ref::WeakReference.new(Object.new)
    ref_2 = Ref::WeakReference.new(Object.new)
    queue.push(ref_1)
    queue.push(ref_2)
    assert_equal ref_1, queue.shift
    assert_equal ref_2, queue.shift
    assert_nil queue.shift
  end
  
  def test_can_remove_references_as_a_stack
    queue = Ref::ReferenceQueue.new
    ref_1 = Ref::WeakReference.new(Object.new)
    ref_2 = Ref::WeakReference.new(Object.new)
    queue.push(ref_1)
    queue.push(ref_2)
    assert_equal ref_2, queue.pop
    assert_equal ref_1, queue.pop
    assert_nil queue.pop
  end
  
  def test_references_are_added_when_the_object_has_been_collected
    Ref::Mock.use do
      obj = Object.new
      ref = Ref::WeakReference.new(obj)
      queue = Ref::ReferenceQueue.new
      queue.monitor(ref)
      assert_nil queue.shift
      Ref::Mock.gc(obj)
      assert_equal ref, queue.shift
    end
  end
  
  def test_references_are_added_immediately_if_the_object_has_been_collected
    Ref::Mock.use do
      obj = Object.new
      ref = Ref::WeakReference.new(obj)
      Ref::Mock.gc(obj)
      queue = Ref::ReferenceQueue.new
      queue.monitor(ref)
      assert_equal ref, queue.shift
    end
  end
end
