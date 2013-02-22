require File.expand_path("../test_helper", __FILE__)

class TestSoftKeyMap < Test::Unit::TestCase
  include ReferenceKeyMapBehavior
  
  def map_class
    Ref::SoftKeyMap
  end
  
  def reference_class
    Ref::SoftReference
  end
end
