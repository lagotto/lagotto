# encoding: UTF-8

module Countable
  extend ActiveSupport::Concern

  included do
    def working_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/working_count/#{update_date}").to_i
      else
        delayed_jobs.count(:locked_at)
      end
    end

    def working_count=(timestamp)
      Rails.cache.write("#{name}/working_count/#{timestamp}",
                        delayed_jobs.count(:locked_at))
    end

    def pending_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/pending_count/#{update_date}").to_i
      else
        delayed_jobs.count(:conditions => ":locked_at IS NULL")
      end
    end

    def pending_count=(timestamp)
      Rails.cache.write("#{name}/pending_count/#{timestamp}",
                        delayed_jobs.count(:conditions => ":locked_at IS NULL"))
    end

    def delayed_jobs_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/delayed_jobs_count/#{update_date}").to_i
      else
        delayed_jobs.count
      end
    end

    def delayed_jobs_count=(timestamp)
      Rails.cache.write("#{name}/delayed_jobs_count/#{timestamp}",
                        delayed_jobs.count)
    end

    def articles_count
      if ActionController::Base.perform_caching
        status_update_date = Rails.cache.read('status:timestamp')
        Rails.cache.read("status/articles_count/#{status_update_date}").to_i
      else

      end
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

    def article_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/article_count/#{update_date}").to_i
      else
      end
    end

    def article_count=(timestamp)
      Rails.cache.write("#{name}/article_count/#{timestamp}",
                        articles.is_cited.size)
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
        api_responses.total(1).size
      end
    end

    def response_count=(timestamp)
      Rails.cache.write("#{name}/response_count/#{timestamp}",
                        api_responses.total(1).size)
    end

    def average_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/average_count/#{update_date}").to_i
      else
        api_responses.total(1).average("duration")
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
        api_responses.total(1).maximum("duration")
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
        retrieval_statuses.with_events(1).size
      end
    end

    def with_events_by_day_count=(timestamp)
      Rails.cache.write("#{name}/with_events_by_day_count/#{timestamp}",
                        retrieval_statuses.with_events(1).size)
    end

    def without_events_by_day_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/without_events_by_day_count/#{update_date}").to_i
      else
        retrieval_statuses.without_events(1).size
      end
    end

    def without_events_by_day_count=(timestamp)
      Rails.cache.write("#{name}/without_events_by_day_count/#{timestamp}",
                        retrieval_statuses.without_events(1).size)
    end

    def with_events_by_month_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/with_events_by_month_count/#{update_date}").to_i
      else
        retrieval_statuses.with_events(31).size
      end
    end

    def with_events_by_month_count=(timestamp)
      Rails.cache.write("#{name}/with_events_by_month_count/#{timestamp}",
                        retrieval_statuses.with_events(31).size)
    end

    def without_events_by_month_count
      if ActionController::Base.perform_caching
        Rails.cache.read("#{name}/without_events_by_month_count/#{update_date}").to_i
      else
        retrieval_statuses.without_events(31).size
      end
    end

    def without_events_by_month_count=(timestamp)
      Rails.cache.write("#{name}/without_events_by_month_count/#{timestamp}",
                        retrieval_statuses.without_events(31).size)
    end
  end
end
