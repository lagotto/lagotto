class Admin::ApiRequestsController < Admin::ApplicationController
  
  def index
    @requests_24_count = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").count
    @requests_24_db_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:db_duration)
    @requests_24_view_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:view_duration)
    @requests_24_page_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:page_duration)
    @requests_30_count = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").count
    @requests_30_db_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:db_duration)
    @requests_30_view_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:view_duration)
    @requests_30_page_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:page_duration)
  end

end