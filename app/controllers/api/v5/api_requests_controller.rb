class Api::V5::ApiRequestsController < Api::V5::BaseController
  load_and_authorize_resource

  def index
    if ActiveRecord::Base.configurations[Rails.env]['adapter'] == "mysql2"
      if params[:key] == "local"
        collection = ApiRequest.where("api_key = ?", ENV['API_KEY'])
      elsif params[:key] == "external"
        collection = ApiRequest.where("api_key != ?", ENV['API_KEY'])
      elsif params[:key]
        collection = ApiRequest.where("api_key = ?", params[:key])
      else
        collection = ApiRequest.where("ids LIKE ?", "Api::%")
      end
    else
      if params[:key] == "local"
        collection = ApiRequest.where("api_key = '?'", ENV['API_KEY'])
      elsif params[:key] == "external"
        collection = ApiRequest.where("api_key != '?'", ENV['API_KEY'])
      elsif params[:key]
        collection = ApiRequest.where("api_key = '?'", params[:key])
      else
        collection = ApiRequest.where("ids LIKE ?", "Api::%")
      end
    end

    @api_requests = collection.order("created_at DESC").paginate(:page => params[:page])
  end
end
