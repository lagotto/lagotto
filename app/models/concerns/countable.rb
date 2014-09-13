# encoding: UTF-8

module Countable
  extend ActiveSupport::Concern

  included do
    def working_count
      delayed_jobs.count(:locked_at)
    end

    def pending_count
      delayed_jobs.count - working_count
    end

    def event_count
      Rails.cache.fetch("#{name}/event_count/#{update_date}") { retrieval_statuses.sum(:event_count) }
    end

    def article_count
      Rails.cache.fetch("#{name}/article_count/#{update_date}") { articles.is_cited.size }
    end

    def status_update_date
      Rails.cache.fetch('status:timestamp') { Time.zone.now.utc.iso8601 }
    end

    def articles_count
      Rails.cache.fetch("status/articles_count/#{status_update_date}") { Article.count }
    end

    def queued_count
      Rails.cache.fetch("#{name}/queued_count/#{update_date}") { retrieval_statuses.queued.size }
    end

    def stale_count
      Rails.cache.fetch("#{name}/stale_count/#{update_date}") { retrieval_statuses.stale.size }
    end

    def response_count
      Rails.cache.fetch("#{name}/response_count/#{update_date}") { api_responses.total(1).size }
    end

    def average_count
      Rails.cache.fetch("#{name}/average_count/#{update_date}") do
        count = api_responses.total(1).average("duration").to_i
        count.nil? ? 0 : count.to_i
      end
    end

    def maximum_count
      Rails.cache.fetch("#{name}/maximum_count/#{update_date}") do
        count = api_responses.total(1).maximum("duration")
        count.nil? ? 0 : count.to_i
      end
    end

    def error_count
      alerts.total_errors(1).size
    end

    def with_events_by_day_count
      Rails.cache.fetch("#{name}/with_events_by_day_count/#{update_date}") do
        retrieval_statuses.with_events(1).size
      end
    end

    def without_events_by_day_count
      Rails.cache.fetch("#{name}/without_events_by_day_count/#{update_date}") do
        retrieval_statuses.without_events(1).size
      end
    end

    def with_events_by_month_count
      Rails.cache.fetch("#{name}/with_events_by_month_count/#{update_date}") do
        retrieval_statuses.with_events(31).size
      end
    end

    def without_events_by_month_count
      Rails.cache.fetch("#{name}/without_events_by_month_count/#{update_date}") do
        retrieval_statuses.without_events(31).size
      end
    end
  end
end
