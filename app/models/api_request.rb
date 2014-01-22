class ApiRequest < ActiveRecord::Base

  def date
    created_at.to_s(:crossfilter)
  end
end