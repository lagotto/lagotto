module Importable
  extend ActiveSupport::Concern

  included do
    def get_total(options={})
      query_url = get_query_url(options.merge(rows: 0))
      result = get_result(query_url, options)
      total = result.fetch("response", {}).fetch("numFound", 0)
    end

    def queue_jobs(options={})
      return 0 unless active?

      query_url = get_query_url(options.merge(rows: 0))
      result = get_result(query_url, options)
      total = result.fetch("response", {}).fetch("numFound", 0)

      if total > 0
        # walk through paginated results
        total_pages = (total.to_f / job_batch_size).ceil

        (0...total_pages).each do |page|
          options[:offset] = page * job_batch_size
          AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(nil, self, options)
        end
      end

      # return number of works queued
      total
    end

    def get_data(_work, options={})
      query_url = get_query_url(options)
      result = get_result(query_url, options)
    end

    def parse_data(result, _work, options={})
      return result if result[:error]

      { works: get_works(result) }
    end

    def cron_line
      config.cron_line || "40 17 * * *"
    end

    def queue
      config.queue || "high"
    end

    def job_batch_size
      config.job_batch_size || 1000
    end

    def tracked
      config.tracked || true
    end
  end
end
