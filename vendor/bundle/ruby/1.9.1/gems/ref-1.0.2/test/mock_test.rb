require File.expand_path("../test_helper", __FILE__)

class TestMock < Test::Unit::TestCase
  def test_gc_with_argument
    Ref::Mock.use do
      obj_1 = Object.new
      obj_2 = Object.new

      ref_1 = Ref::WeakReference.new(obj_1)
      ref_2 = Ref::WeakReference.new(obj_2)

      Ref::Mock.gc(obj_1)

      assert_nil ref_1.object
      assert_equal ref_2.object, obj_2
    end
  end

  def test_gc_with_no_argument
    Ref::Mock.use do
      obj_1 = Object.new
      obj_2 = Object.new

      ref_1 = Ref::WeakReference.new(obj_1)
      ref_2 = Ref::WeakReference.new(obj_2)

      Ref::Mock.gc

      assert_nil ref_1.object
      assert_nil ref_2.object
    end
  end
end
