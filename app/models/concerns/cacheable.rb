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
        Source.order_by_name.pluck(:id, :name, :title).map { |i| [i[0], { name: i[1], title: i[2] }] }.to_h
      end
    end
  end

  module ClassMethods
    def cached_work_count
      Rails.cache.fetch("work_count", expires_in: 1.hour) do
        Work.tracked.count
      end
    end

    def cached_deposit_count
      Rails.cache.fetch("deposit_count", expires_in: 1.hour) do
        Deposit.count
      end
    end

    def cached_deposit_state_count(state)
      Rails.cache.fetch("deposit_state_count/#{state}", expires_in: 1.hour) do
        Deposit.where(state: state).count
      end
    end

    def cached_deposit_source_token_count(source_token)
      Rails.cache.fetch("deposit_source_token_count/#{source_token}", expires_in: 1.hour) do
        Deposit.where(source_token: source_token).count
      end
    end

    def cached_deposit_source_token_state_count(source_token, state)
      Rails.cache.fetch("deposit_source_token_statecount/#{source_token}-#{state}", expires_in: 1.hour) do
        Deposit.where(source_token: source_token).where(state: state).count
      end
    end
  end
end
