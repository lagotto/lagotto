class ApiRequest < ActiveRecord::Base
  scope :total, ->(duration) { where("created_at > ?", Time.zone.now.to_date - duration.days) }

  def self.per_page
    1000
  end

  def date
    created_at.utc.iso8601
  end
end
