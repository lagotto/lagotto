module Ref
  # This module provides mock weak and strong references that are designed to be
  # used in tests. You can define a block where all weak and soft references created
  # will be mock references. You can then mimic running the garbage collector on
  # the objects pointed to by the references.
  #
  # Example usage:
  #
  #   Ref::Mock.use do
  #     obj = Object.new
  #     ref = Ref::WeakReference.new(obj)
  #     ref.object   # obj
  #     Ref::Mock.gc(obj)  # mimics the garbage collector reclaiming the referenced object
  #     ref.object   # nil
  #   end
  module Mock
    class << self
      # Use the mock implementation inside a block and then restore the original implementation.
      def use
        if object_space
          yield
        else
          setup
          begin
            yield
          ensure
            cleanup
          end
        end
      end
      
      # Start using mock references.
      def setup
        raise "Ref::Mock already setup" if object_space
        
        @object_space = {}
        
        class << ObjectSpace
          unless method_defined?(:define_finalizer_with_mock_reference)
            def define_finalizer_with_mock_reference(obj, finalizer)
              if ::Ref::Mock.object_space.include?(obj.__id__)
                ::Ref::Mock.object_space[obj.__id__] << finalizer
              else
                define_finalizer_without_mock_reference(obj, finalizer)
              end
            end
          end
          
          alias_method :define_finalizer_without_mock_reference, :define_finalizer
          alias_method :define_finalizer, :define_finalizer_with_mock_reference
        end
        
        class << WeakReference
          unless method_defined?(:new_with_mock_reference)
            def new_with_mock_reference(obj)
              if self == Mock::MockWeakReference
                new_without_mock_reference(obj)
              else
                Mock::MockWeakReference.new(obj)
              end
            end
          end
          
          alias_method :new_without_mock_reference, :new
          alias_method :new, :new_with_mock_reference
        end
        
        class << SoftReference
          unless method_defined?(:new_with_mock_reference)
            def new_with_mock_reference(obj)
              if self == Mock::MockSoftReference
                new_without_mock_reference(obj)
              else
                Mock::MockSoftReference.new(obj)
              end
            end
          end
          
          alias_method :new_without_mock_reference, :new
          alias_method :new, :new_with_mock_reference
        end
      end
      
      # Stop using mock references.
      def cleanup
        @object_space = nil
        class << ObjectSpace
          alias_method :define_finalizer_with_mock_reference, :define_finalizer
          alias_method :define_finalizer, :define_finalizer_without_mock_reference
        end
        
        class << WeakReference
          alias_method :new_with_mock_reference, :new
          alias_method :new, :new_without_mock_reference
        end
        
        class << SoftReference
          alias_method :new_with_mock_reference, :new
          alias_method :new, :new_without_mock_reference
        end
      end

      def object_space # :nodoc:
        @object_space if instance_variable_defined?(:@object_space)
      end

      # Simulate garbage collection of the objects passed in as arguments. If no objects
      # are specified, all objects will be reclaimed.
      def gc(*objects)
        objects = if objects.empty?
          object_space.keys
        else
          objects.map { |obj| obj.__id__ }
        end

        objects.each do |id|
          finalizers = object_space.delete(id)
          if finalizers
            finalizers.each{|finalizer| finalizer.call(id)}
          end
        end
      end
    end
    
    module MockReference #:nodoc:
      def initialize(obj)
        @object = obj
        @referenced_object_id = obj.__id__
        raise "Reference::Mock not setup yet" unless Mock.object_space
        Mock.object_space[obj.__id__] ||= []
      end
    
      def object
        if @object && Mock.object_space.include?(@object.__id__)
          @object
        else
          @object = nil
        end
      end
    end
  
    class MockWeakReference < WeakReference #:nodoc:
      include MockReference
    end
  
    class MockSoftReference < SoftReference #:nodoc:
      include MockReference
    end
  end  
end
