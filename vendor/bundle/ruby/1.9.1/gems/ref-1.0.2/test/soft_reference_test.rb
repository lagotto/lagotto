require File.expand_path("../test_helper", __FILE__)

class TestSoftReference < Test::Unit::TestCase
  def test_can_get_non_garbage_collected_objects
    obj = Object.new
    ref = Ref::SoftReference.new(obj)
    assert_equal obj, ref.object
    assert_equal obj.object_id, ref.referenced_object_id
  end

  def test_get_the_correct_object
    # Since we can't reliably control the garbage collector, this is a brute force test.
    # It might not always fail if the garbage collector and memory allocator don't
    # cooperate, but it should fail often enough on continuous integration to
    # hilite any problems. Set the environment variable QUICK_TEST to "true" if you
    # want to make the tests run quickly.
    id_to_ref = {}
    (ENV["QUICK_TEST"] == "true" ? 1000 : 100000).times do |i|
      obj = Object.new
      if id_to_ref.key?(obj.object_id)
        ref = id_to_ref[obj.object_id]
        if ref.object
          flunk "soft reference found with a live reference to an object that was not the one it was created with"
          break
        end
      end
      %w(Here are a bunch of objects that are allocated and can then be cleaned up by the garbage collector)
      id_to_ref[obj.object_id] = Ref::SoftReference.new(obj)
      if i % 1000 == 0
        GC.start
        sleep(0.01)
      end
    end
  end
  
  def test_references_are_not_collected_immediately
    ref = Ref::SoftReference.new(Object.new)
    9.times{arr = %w(allocate some memory on the heap); arr *= 100; GC.start}
    assert ref.object
  end
  
  def test_inspect
    ref = Ref::SoftReference.new(Object.new)
    assert ref.inspect
    GC.start
    GC.start
    assert ref.inspect
  end
end
