class Admin::ApiRequestsController < Admin::ApplicationController

  load_and_authorize_resource

  def index
    @api_keys = User.where("role != 'user'").pluck(:authentication_token)
    api_requests = ApiRequest.order("created_at DESC").limit(10000)
    @data = api_requests.map { |api_request| { "api_key" => api_request.api_key,
                                               "info" => api_request.info,
                                               "source" => api_request.source,
                                               "ids" => api_request.ids,
                                               "db_duration" => api_request.db_duration,
                                               "view_duration" => api_request.view_duration,
                                               "date" => api_request.created_at.to_s(:crossfilter) } }.to_json
  end

end
