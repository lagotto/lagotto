module Cacheable
  extend ActiveSupport::Concern

  included do
    def cached_source(name)
      Rails.cache.fetch("source/#{name}", expires_in: 1.month) do
        Source.where(name: name).first
      end
    end

    def cached_publisher(name)
      Rails.cache.fetch("publisher/#{name}", expires_in: 1.month) do
        Publisher.where(name: name).first
      end
    end

    def cached_relation_type(name)
      Rails.cache.fetch("relation_type/#{name}", expires_in: 1.month) do
        RelationType.where(name: name).first
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

    def cached_prefix(name)
      Rails.cache.fetch("prefix/#{name}", expires_in: 1.month) do
        Prefix.where(prefix: name).first
      end
    end
  end
end
