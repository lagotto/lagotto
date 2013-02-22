require File.expand_path("../test_helper", __FILE__)

class TestWeakValueMap < Test::Unit::TestCase
  include ReferenceValueMapBehavior
  
  def map_class
    Ref::WeakValueMap
  end
  
  def reference_class
    Ref::WeakReference
  end
end
