module Coverable
  extend ActiveSupport::Concern

  included do
    def get_query_url(options={})
      work = Work.where(id: options.fetch(:work_id, nil)).first
      return {} unless work.present? && work.doi =~ /^10.1371/

      url_private % { :doi => work.doi_escaped }
    end

    def get_events_url(options={})
      nil
    end

    def config_fields
      [:url_private]
    end
  end
end
