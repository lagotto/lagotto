class Admin::ApiRequestsController < Admin::ApplicationController
  
  load_and_authorize_resource 
  
  def index
    api_requests = ApiRequest.order("created_at DESC").limit(10000)
    @data = api_requests.map { |api_request| { "url" => api_request.path[17..100],
                                               "db_duration" => api_request.db_duration,
                                               "view_duration" => api_request.view_duration, 
                                               "date" => api_request.created_at.to_s(:crossfilter) } }.to_json
  end

end