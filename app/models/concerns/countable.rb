module Countable
  extend ActiveSupport::Concern

  included do
    def works_count
      Status.create(current_version: Lagotto::VERSION) if Status.count == 0
      Status.first.works_count
    end

    def event_count
      cache_read("event_count", results.sum(:total))
    end

    def event_count=(time)
      cache_write("event_count", results.sum(:total), time)
    end

    def work_count
      cache_read("work_count", works.has_results.size)
    end

    def work_count=(time)
      cache_write("work_count", works.has_results.size, time)
    end

    def relation_count
      cache_read("relation_count", results.size)
    end

    def relation_count=(time)
      cache_write("relation_count", results.size, time)
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

    def with_results_by_day_count
      cache_read("with_results_by_day_count", results.with_results.last_x_days(1).size)
    end

    def with_results_by_day_count=(time)
      cache_write("with_results_by_day_count", results.with_results.last_x_days(1).size, time)
    end

    def without_results_by_day_count
      cache_read("without_results_by_day_count", results.without_results.last_x_days(1).size)
    end

    def without_results_by_day_count=(time)
      cache_write("without_results_by_day_count", results.without_results.last_x_days(1).size, time)
    end

    def not_updated_by_day_count
      cache_read("not_updated_by_day_count", results.not_updated(1).size)
    end

    def not_updated_by_day_count=(time)
      cache_write("not_updated_by_day_count", results.not_updated(1).size, time)
    end

    def with_results_by_month_count
      cache_read("with_results_by_month_count", results.with_results.last_x_days(31).size)
    end

    def with_results_by_month_count=(time)
      cache_write("with_results_by_month_count", results.with_results.last_x_days(31).size, time)
    end

    def without_results_by_month_count
      cache_read("without_results_by_month_count", results.without_results.last_x_days(31).size)
    end

    def without_results_by_month_count=(time)
      cache_write("without_results_by_month_count", results.without_results.last_x_days(31).size, time)
    end

    def not_updated_by_month_count
      cache_read("not_updated_by_month_count", results.not_updated(31).size)
    end

    def not_updated_by_month_count=(time)
      cache_write("not_updated_by_month_count", results.not_updated(31).size, time)
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
