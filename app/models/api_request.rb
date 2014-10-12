class ApiRequest < ActiveRecord::Base
  scope :total, lambda { |duration| where("created_at > ?", Time.zone.now - duration.days) }

  def self.per_page
    10000
  end

  def date
    created_at.utc.iso8601
  end
end
