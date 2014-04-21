class ApiRequest < ActiveRecord::Base
  def date
    created_at.utc.iso8601
  end

  def self.per_page
    10000
  end
end
