begin
  require 'thread'
rescue LoadError
  # Threads not available. Monitor will do nothing.
end

module Ref
  # The Monitor class in Ruby 1.8 has some bugs and also threads may not be available on all
  # runtimes. This class provides a simple, safe re-entrant mutex as an alternative.
  class SafeMonitor
    def initialize
      @owner = nil
      @count = 0
      @mutex = defined?(Mutex) ? Mutex.new : nil
    end
  
    # Acquire an exclusive lock.
    def lock
      if @mutex
        if @owner != Thread.current.object_id
          @mutex.lock
          @owner = Thread.current.object_id
        end
        @count += 1
      end
      true
    end
    
    # Release the exclusive lock.
    def unlock
      if @mutex
        if @owner == Thread.current.object_id
          @count -= 1
          if @count == 0
            @owner = nil
            @mutex.unlock
          end
        end
      end
    end
  
    # Run a block of code with an exclusive lock.
    def synchronize
      lock
      yield
    ensure
      unlock
    end
  end
end
