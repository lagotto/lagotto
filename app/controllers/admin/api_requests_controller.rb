class Admin::ApiRequestsController < Admin::ApplicationController
  
  def index
    # @requests_24_count = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").count
    # @requests_24_db_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:db_duration)
    # @requests_24_view_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:view_duration)
    # @requests_24_page_average = ApiRequest.where("created_at > NOW() - INTERVAL 24 HOUR").average(:page_duration)
    # @requests_30_count = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").count
    # @requests_30_db_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:db_duration)
    # @requests_30_view_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:view_duration)
    # @requests_30_page_average = ApiRequest.where("created_at > NOW() - INTERVAL 30 DAY").average(:page_duration)
    
    api_requests = ApiRequest.where("created_at > NOW() - INTERVAL 42 DAY")
    @data = api_requests.map { |api_request| { "url" => api_request.path[17..100],
                                               "db_duration" => api_request.db_duration,
                                               "view_duration" => api_request.view_duration, 
                                               "date" => api_request.created_at.to_s(:crossfilter) } }.to_json
  end

end