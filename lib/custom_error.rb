module CustomError
  # source is either inactive or disabled
  class SourceInactiveError < StandardError; end

  # more requests than rate-limits allow
  class TooManyRequestsError < StandardError; end

  # we have received too many errors (and will disable the source)
  class TooManyErrorsBySourceError < StandardError; end

  # we don't have enough available workers for this source
  class NotEnoughWorkersError < StandardError; end

  # something went wrong with Active Job
  class ActiveJobError < StandardError; end

  # Default filter error
  class ApiResponseError < StandardError; end
end
