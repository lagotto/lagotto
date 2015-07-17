module Dataoneable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, work, options={})
      return result if result[:error]

      total = result.fetch("response", {}).fetch("numFound", 0)
      months = total > 0 ? get_events_by_month(result) : []

      { events: {
          source: name,
          work: work.pid,
          total: total,
          months: months } }
    end

    def get_events_by_month(result)
      counts = result.deep_fetch("facet_counts", "facet_ranges", "dateLogged", "counts") { [] }
      counts.each_slice(2).map do |item|
        year, month = *get_year_month(item.first)

        { month: month,
          year: year,
          total: item.last }
      end
    end

    def config_fields
      [:url]
    end

    def url
      "https://cn.dataone.org/cn/v1/query/logsolr/select?"
    end

    def cron_line
      config.cron_line || "* 4 * * *"
    end

    def queue
      config.queue || "high"
    end
  end
end
