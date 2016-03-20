module Dataoneable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, options={})
      return [result] if result[:error]

      work = Work.where(id: options.fetch(:work_id, nil)).first
      return [{ error: "Resource not found.", status: 404 }] unless work.present?

      total = result.fetch("response", {}).fetch("numFound", 0)
      months = total > 0 ? get_events_by_month(result) : []

      subj_id = "https://www.dataone.org"
      subj = { "pid" => subj_id,
               "URL" => subj_id,
               "title" => "DataONE",
               "type" => "webpage",
               "issued" => "2012-05-15T16:40:23Z" }

      relations = []
      if total > 0
        relations << { relation: { "subj_id" => subj_id,
                                   "obj_id" => work.pid,
                                   "relation_type_id" => "downloads",
                                   "total" => total,
                                   "source_id" => source_id },
                       subj: subj }
      end

      relations
    end

    # def get_events_by_month(result)
    #   counts = result.deep_fetch("facet_counts", "facet_ranges", "dateLogged", "counts") { [] }
    #   counts.each_slice(2).map do |item|
    #     year, month = *get_year_month(item.first)

    #     { month: month,
    #       year: year,
    #       total: item.last }
    #   end
    # end

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
