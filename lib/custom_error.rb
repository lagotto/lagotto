module CustomError
  # source is either inactive or disabled
  class SourceInactiveError < Exception; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < Exception; end

  # we don't have enough available workers for this source
  class NotEnoughWorkersError < Exception; end

  # something went wrong with Delayed Job
  class DelayedJobError < Exception; end

  # Default filter error
  class ApiResponseError < Exception; end
end