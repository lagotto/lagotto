class ActiveJob::Base
  # monkey patch for ActiveJob bug, see https://github.com/rails/rails/issues/22044
  def serialize
    result = super
    if result['arguments'].empty? && @serialized_arguments && @serialized_arguments.any?
      result['arguments'] = @serialized_arguments
    end
    result
  end
end
