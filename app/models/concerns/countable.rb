module Countable
  extend ActiveSupport::Concern

  included do
    def works_count
      Status.first.works_count
    end

    def event_count
      cache_read("event_count", retrieval_statuses.sum(:event_count))
    end

    def event_count=
      cache_write("event_count", retrieval_statuses.sum(:event_count))
    end

    def work_count
      cache_read("work_count", works.has_events.size)
    end

    def work_count=
      cache_write("work_count", works.has_events.size)
    end

    def relative_work_count
      if works_count > 0
        work_count * 100.0 / works_count
      else
        0
      end
    end

    def queued_count
      cache_read("queued_count", retrieval_statuses.queued.size)
    end

    def queued_count=
      cache_write("queued_count", retrieval_statuses.queued.size)
    end

    def stale_count
      cache_read("stale_count", retrieval_statuses.stale.size)
    end

    def stale_count=
      cache_write("stale_count", retrieval_statuses.stale.size)
    end

    def response_count
      cache_read("response_count", api_responses.total(24).size)
    end

    def response_count=
      cache_write("response_count/", api_responses.total(24).size)
    end

    def average_count
      cache_read("average_count", api_responses.total(1).average("duration").to_i)
    end

    def average_count=
      cache_write("average_count", api_responses.total(1).average("duration"))
    end

    def maximum_count
      cache_read("maximum_count", api_responses.total(1).maximum("duration").to_i)
    end

    def maximum_count=
      cache_write("maximum_count", api_responses.total(1).maximum("duration"))
    end

    def error_count
      alerts.total_errors(1).size
    end

    def with_events_by_day_count
      cache_read("with_events_by_day_count", retrieval_statuses.with_events.last_x_days(1).size)
    end

    def with_events_by_day_count=
      cache_write("with_events_by_day_count", retrieval_statuses.with_events.last_x_days(1).size)
    end

    def without_events_by_day_count
      cache_read("without_events_by_day_count", retrieval_statuses.without_events.last_x_days(1).size)
    end

    def without_events_by_day_count=
      cache_write("without_events_by_day_count", retrieval_statuses.without_events.last_x_days(1).size)
    end

    def with_events_by_month_count
      cache_read("with_events_by_month_count", retrieval_statuses.with_events.last_x_days(31).size)
    end

    def with_events_by_month_count=
      cache_write("with_events_by_month_count", retrieval_statuses.with_events.last_x_days(31).size)
    end

    def without_events_by_month_count
      cache_read("without_events_by_month_count", retrieval_statuses.without_events.last_x_days(31).size)
    end

    def without_events_by_month_count=
      cache_write("without_events_by_month_count", retrieval_statuses.without_events.last_x_days(31).size)
    end

    def cache_read(id, value)
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/#{id}/#{update_date}").to_i
      else
        value
      end
    end

    def cache_write(id, value)
      Rails.cache.write("#{name}/#{id}/#{Time.zone.now.utc.iso8601}", value)
    end
  end
end
