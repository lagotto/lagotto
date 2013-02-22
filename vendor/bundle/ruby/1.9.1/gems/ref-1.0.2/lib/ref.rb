module Ref
  autoload :AbstractReferenceValueMap, File.join(File.dirname(__FILE__), "ref", "abstract_reference_value_map.rb")
  autoload :AbstractReferenceKeyMap, File.join(File.dirname(__FILE__), "ref", "abstract_reference_key_map.rb")
  autoload :Mock, File.join(File.dirname(__FILE__), "ref", "mock.rb")
  autoload :Reference, File.join(File.dirname(__FILE__), "ref", "reference.rb")
  autoload :ReferenceQueue, File.join(File.dirname(__FILE__), "ref", "reference_queue.rb")
  autoload :SafeMonitor, File.join(File.dirname(__FILE__), "ref", "safe_monitor.rb")
  autoload :SoftKeyMap, File.join(File.dirname(__FILE__), "ref", "soft_key_map.rb")
  autoload :SoftValueMap, File.join(File.dirname(__FILE__), "ref", "soft_value_map.rb")
  autoload :StrongReference, File.join(File.dirname(__FILE__), "ref", "strong_reference.rb")
  autoload :WeakKeyMap, File.join(File.dirname(__FILE__), "ref", "weak_key_map.rb")
  autoload :WeakValueMap, File.join(File.dirname(__FILE__), "ref", "weak_value_map.rb")

  # Set the best implementation for weak references based on the runtime.
  if defined?(RUBY_PLATFORM) && RUBY_PLATFORM == 'java'
    # Use native Java references
    begin
      $LOAD_PATH.unshift(File.dirname(__FILE__))
      require 'org/jruby/ext/ref/references'
    ensure
      $LOAD_PATH.shift if $LOAD_PATH.first == File.dirname(__FILE__)
    end
  else
    autoload :SoftReference, File.join(File.dirname(__FILE__), "ref", "soft_reference.rb")
    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ironruby'
      # IronRuby has it's own implementation of weak references.
      autoload :WeakReference, File.join(File.dirname(__FILE__), "ref", "weak_reference", "iron_ruby.rb")
    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      # If using Rubinius set the implementation to use WeakRef since it is very efficient and using finalizers is not.
      autoload :WeakReference, File.join(File.dirname(__FILE__), "ref", "weak_reference", "weak_ref.rb")
    elsif defined?(ObjectSpace._id2ref)
      # If ObjectSpace can lookup objects from their object_id, then use the pure ruby implementation.
      autoload :WeakReference, File.join(File.dirname(__FILE__), "ref", "weak_reference", "pure_ruby.rb")
    else
      # Otherwise, wrap the standard library WeakRef class
      autoload :WeakReference, File.join(File.dirname(__FILE__), "ref", "weak_reference", "weak_ref.rb")
    end
  end
end
