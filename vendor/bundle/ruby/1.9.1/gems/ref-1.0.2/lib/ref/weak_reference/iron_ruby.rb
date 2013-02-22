module Ref
  class WeakReference < Reference
  # This implementation of a weak reference wraps the System::WeakReference class
  # that comes with IronRuby.
    def initialize(obj) #:nodoc:
      @referenced_object_id = obj.__id__
      @ref = ::System::WeakReference.new(obj)
    end

    def object #:nodoc:
      @ref.target
    end
  end
end
