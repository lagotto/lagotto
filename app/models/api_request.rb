class ApiRequest < ActiveRecord::Base

  def date
    created_at.to_s(:crossfilter)
  end

  def self.per_page
    1000
  end
end