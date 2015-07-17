module Dataoneable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, work, options={})
      return result if result[:error]

      extra = get_extra(result)

      pdf = get_sum(extra, "pdf_views")
      html = get_sum(extra, "html_views")
      xml = get_sum(extra, "xml_views")
      total = pdf + html + xml

      { events: {
          source: name,
          work: work.pid,
          pdf: pdf,
          html: html,
          total: total,
          months: get_events_by_month(extra) } }
    end

    def get_events_by_month(extra)
      extra.map do |month|
        html = month["html_views"].to_i
        pdf = month["pdf_views"].to_i
        xml = month["xml_views"].to_i

        { month: month["month"].to_i,
          year: month["year"].to_i,
          html: html,
          pdf: pdf,
          total: html + pdf + xml }
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
