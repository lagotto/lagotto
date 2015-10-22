module Countable
  extend ActiveSupport::Concern

  included do
    def works_count
      Status.create(current_version: Lagotto::VERSION) if Status.count == 0
      Status.first.works_count
    end

    def event_count
      cache_read("event_count", events.sum(:total))
    end

    def event_count=(time)
      cache_write("event_count", events.sum(:total), time)
    end

    def work_count
      cache_read("work_count", works.has_events.size)
    end

    def work_count=(time)
      cache_write("work_count", works.has_events.size, time)
    end

    def relation_count
      cache_read("relation_count", relations.size)
    end

    def relation_count=(time)
      cache_write("relation_count", relations.size, time)
    end

    def relative_work_count
      if works_count > 0
        work_count * 100.0 / works_count
      else
        0
      end
    end

    def response_count
      cache_read("response_count", api_responses.total(24).size)
    end

    def response_count=(time)
      cache_write("response_count", api_responses.total(24).size, time)
    end

    def average_count
      cache_read("average_count", api_responses.total(24).average("duration").to_i)
    end

    def average_count=(time)
      cache_write("average_count", api_responses.total(24).average("duration"), time)
    end

    def maximum_count
      cache_read("maximum_count", api_responses.total(24).maximum("duration").to_i)
    end

    def maximum_count=(time)
      cache_write("maximum_count", api_responses.total(24).maximum("duration"), time)
    end

    def error_count
      notifications.total_errors(1).size
    end

    def with_events_by_day_count
      cache_read("with_events_by_day_count", events.with_events.last_x_days(1).size)
    end

    def with_events_by_day_count=(time)
      cache_write("with_events_by_day_count", events.with_events.last_x_days(1).size, time)
    end

    def without_events_by_day_count
      cache_read("without_events_by_day_count", events.without_events.last_x_days(1).size)
    end

    def without_events_by_day_count=(time)
      cache_write("without_events_by_day_count", events.without_events.last_x_days(1).size, time)
    end

    def not_updated_by_day_count
      cache_read("not_updated_by_day_count", events.not_updated(1).size)
    end

    def not_updated_by_day_count=(time)
      cache_write("not_updated_by_day_count", events.not_updated(1).size, time)
    end

    def with_events_by_month_count
      cache_read("with_events_by_month_count", events.with_events.last_x_days(31).size)
    end

    def with_events_by_month_count=(time)
      cache_write("with_events_by_month_count", events.with_events.last_x_days(31).size, time)
    end

    def without_events_by_month_count
      cache_read("without_events_by_month_count", events.without_events.last_x_days(31).size)
    end

    def without_events_by_month_count=(time)
      cache_write("without_events_by_month_count", events.without_events.last_x_days(31).size, time)
    end

    def not_updated_by_month_count
      cache_read("not_updated_by_month_count", events.not_updated(31).size)
    end

    def not_updated_by_month_count=(time)
      cache_write("not_updated_by_month_count", events.not_updated(31).size, time)
    end

    def cache_read(id, value)
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/#{id}/#{timestamp}").to_i
      else
        value
      end
    end

    def cache_write(id, value, time)
      Rails.cache.write("#{name}/#{id}/#{time}", value)
    end
  end
end
