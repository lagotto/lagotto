module Cacheable
  extend ActiveSupport::Concern

  included do
    def cached_source(name)
      Rails.cache.fetch("source/#{name}", expires_in: 1.month) do
        Source.where(name: name).first
      end
    end

    def cached_source_names
      Rails.cache.fetch("source/names", expires_in: 1.month) do
        Source.order_by_name.pluck(:id, :name).to_h
      end
    end

    def cached_publisher(name)
      Rails.cache.fetch("publisher/#{name}", expires_in: 1.month) do
        Publisher.where(name: name).first
      end
    end

    def cached_publisher_id(id)
      Rails.cache.fetch("publisher/#{id}", expires_in: 1.month) do
        Publisher.where(id: id).first
      end
    end

    def cached_registration_agency(name)
      Rails.cache.fetch("registration_agency/#{name}", expires_in: 1.month) do
        RegistrationAgency.where(name: name).first
      end
    end

    def cached_registration_agency_id(id)
      Rails.cache.fetch("registration_agency/#{id}", expires_in: 1.month) do
        RegistrationAgency.where(id: id).first
      end
    end

    def cached_registration_agency_names
      Rails.cache.fetch("registration_agency/names", expires_in: 1.month) do
        RegistrationAgency.order_by_name.pluck(:id, :name).to_h
      end
    end

    def cached_relation_type(name)
      Rails.cache.fetch("relation_type/#{name}", expires_in: 1.month) do
        RelationType.where(name: name).first
      end
    end

    def cached_relation_type_names
      Rails.cache.fetch("relation_type/names", expires_in: 1.month) do
        RelationType.order(:name).pluck(:id, :name).to_h
      end
    end

    def cached_inv_relation_type(name)
      Rails.cache.fetch("inv_relation_type/#{name}", expires_in: 1.month) do
        RelationType.where(inverse_name: name).first
      end
    end

    def cached_work_type(name)
      Rails.cache.fetch("work_type/#{name}", expires_in: 1.month) do
        WorkType.where(name: name).first
      end
    end

    def cached_work_type_names
      Rails.cache.fetch("work_type/names", expires_in: 1.month) do
        WorkType.pluck(:id, :name).to_h
      end
    end

    def cached_prefix(name)
      Rails.cache.fetch("prefix/#{name}", expires_in: 1.month) do
        Prefix.where(name: name).first
      end
    end

    def cached_contributor_role(name)
      Rails.cache.fetch("contributor_role/#{name}", expires_in: 1.month) do
        ContributorRole.where(name: name).first
      end
    end

    def cached_contributor_role_names
      Rails.cache.fetch("contributor_role/names", expires_in: 1.month) do
        ContributorRole.order(:name).pluck(:id, :name).to_h
      end
    end
  end
end
