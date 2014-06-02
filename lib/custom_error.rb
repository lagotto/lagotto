module CustomError
  # source is either inactive or disabled
  class SourceInactiveError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end

  # we don't have enough available workers for this source
  class NotEnoughWorkersError < StandardError; end

  # something went wrong with Delayed Job
  class DelayedJobError < StandardError; end

  # Default filter error
  class ApiResponseError < StandardError; end
end
