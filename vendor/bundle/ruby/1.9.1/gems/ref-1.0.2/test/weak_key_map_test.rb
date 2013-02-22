require File.expand_path("../test_helper", __FILE__)

class TestWeakKeyMap < Test::Unit::TestCase
  include ReferenceKeyMapBehavior
  
  def map_class
    Ref::WeakKeyMap
  end
  
  def reference_class
    Ref::WeakReference
  end
end
