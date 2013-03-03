class Admin::ApiRequestsController < Admin::ApplicationController
  
  def index
    api_requests = ApiRequest.where("created_at > NOW() - INTERVAL 42 DAY")
    @data = api_requests.map { |api_request| { "url" => api_request.path[17..100],
                                               "db_duration" => api_request.db_duration,
                                               "view_duration" => api_request.view_duration, 
                                               "date" => api_request.created_at.to_s(:crossfilter) } }.to_json
  end

end