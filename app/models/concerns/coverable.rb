module Coverable
  extend ActiveSupport::Concern

  included do
    def get_query_url(options={})
      work = Work.where(id: options.fetch(:work_id, nil)).first
      return {} unless work.present? && work.prefix == "10.1371"

      url_private % { :doi => work.doi_escaped }
    end

    def config_fields
      [:url_private]
    end
  end
end
