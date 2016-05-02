class ActiveJob::Base
  def serialize
    result = super
    if result['arguments'].empty? && @serialized_arguments && @serialized_arguments.any?
      result['arguments'] = @serialized_arguments
    end
    result
  end
end
