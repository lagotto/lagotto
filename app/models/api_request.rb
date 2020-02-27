class ApiRequest < ApplicationRecord
  scope :total, ->(duration) { where(created_at: (Time.zone.now.beginning_of_hour - duration.hours)..Time.zone.now.beginning_of_hour) }

  def self.per_page
    1000
  end

  def to_param
    uuid
  end

  def timestamp
    created_at.utc.iso8601
  end

  def cache_key
    "api_request/#{uuid}/#{timestamp}"
  end
end
