#
# ActiveSupport patch
# This will not work in rails 3.2
#
module ActiveSupport

  # Format the buffered logger with timestamp
  class BufferedLogger

    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      message = "#{Time.now.strftime('%F %T %z')} #{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end

  end
end
