class ApiRequest < ActiveRecord::Base
  def date
    created_at.utc.iso8601
  end

  def self.per_page
    1000
  end
end
