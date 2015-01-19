module Countable
  extend ActiveSupport::Concern

  included do
    def works_count
      Status.first.works_count
    end

    def event_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/event_count/#{update_date}").to_i
      else
        retrieval_statuses.sum(:event_count)
      end
    end

    def event_count=(timestamp)
      Rails.cache.write("#{name}/event_count/#{timestamp}",
                        retrieval_statuses.sum(:event_count))
    end

    def work_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/work_count/#{update_date}").to_i
      else
        works.has_events.size
      end
    end

    def work_count=(timestamp)
      Rails.cache.write("#{name}/work_count/#{timestamp}",
                        works.has_events.size)
    end

    def relative_work_count
      if works_count > 0
        work_count * 100.0 / works_count
      else
        0
      end
    end

    def queued_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/queued_count/#{update_date}").to_i
      else
        retrieval_statuses.queued.size
      end
    end

    def queued_count=(timestamp)
      Rails.cache.write("#{name}/queued_count/#{timestamp}",
                        retrieval_statuses.queued.size)
    end

    def stale_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/stale_count/#{update_date}").to_i
      else
        retrieval_statuses.stale.size
      end
    end

    def stale_count=(timestamp)
      Rails.cache.write("#{name}/stale_count/#{timestamp}",
                        retrieval_statuses.stale.size)
    end

    def response_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/response_count/#{update_date}").to_i
      else
        api_responses.total(24).size
      end
    end

    def response_count=(timestamp)
      Rails.cache.write("#{name}/response_count/#{timestamp}",
                        api_responses.total(24).size)
    end

    def average_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/average_count/#{update_date}").to_i
      else
        api_responses.total(1).average("duration").to_i
      end
    end

    def average_count=(timestamp)
      Rails.cache.write("#{name}/average_count/#{timestamp}",
                        api_responses.total(1).average("duration"))
    end

    def maximum_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/maximum_count/#{update_date}").to_i
      else
        api_responses.total(1).maximum("duration").to_i
      end
    end

    def maximum_count=(timestamp)
      Rails.cache.write("#{name}/maximum_count/#{timestamp}",
                        api_responses.total(1).maximum("duration"))
    end

    def error_count
      alerts.total_errors(1).size
    end

    def with_events_by_day_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/with_events_by_day_count/#{update_date}").to_i
      else
        retrieval_statuses.with_events.last_x_days(1).size
      end
    end

    def with_events_by_day_count=(timestamp)
      Rails.cache.write("#{name}/with_events_by_day_count/#{timestamp}",
                        retrieval_statuses.with_events.last_x_days(1).size)
    end

    def without_events_by_day_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/without_events_by_day_count/#{update_date}").to_i
      else
        retrieval_statuses.without_events.last_x_days(1).size
      end
    end

    def without_events_by_day_count=(timestamp)
      Rails.cache.write("#{name}/without_events_by_day_count/#{timestamp}",
                        retrieval_statuses.without_events.last_x_days(1).size)
    end

    def with_events_by_month_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/with_events_by_month_count/#{update_date}").to_i
      else
        retrieval_statuses.with_events.last_x_days(31).size
      end
    end

    def with_events_by_month_count=(timestamp)
      Rails.cache.write("#{name}/with_events_by_month_count/#{timestamp}",
                        retrieval_statuses.with_events.last_x_days(31).size)
    end

    def without_events_by_month_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/without_events_by_month_count/#{update_date}").to_i
      else
        retrieval_statuses.without_events.last_x_days(31).size
      end
    end

    def without_events_by_month_count=(timestamp)
      Rails.cache.write("#{name}/without_events_by_month_count/#{timestamp}",
                        retrieval_statuses.without_events.last_x_days(31).size)
    end
  end
end
