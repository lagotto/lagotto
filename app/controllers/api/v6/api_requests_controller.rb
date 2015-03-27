class Api::V6::ApiRequestsController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  swagger_controller :api_requests, "API requests"

  swagger_api :index do
    summary "Returns all API requests"
    notes "Authentication with a valid API key with staff or admin permissions is required. Returns 1,000 results per page."
    param :query, :apiKey, :string, :required, "API key"
    param :query, :key, :string, :optional, "Key, either a specific API key or one of internal, external, or other"
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :unauthorized
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    collection = ApiRequest

    if ActiveRecord::Base.configurations[Rails.env]['adapter'] == "mysql2"
      if params[:q]
        collection = collection.where("api_key = ?", params[:q])
      elsif params[:key] == "internal"
        collection = collection.where("api_key = ?", ENV['API_KEY'])
      elsif params[:key] == "external"
        collection = collection.where("api_key != ?", ENV['API_KEY'])
      elsif params[:key] == "other"
        collection = collection.where("ids LIKE ?", "Api::%")
      end
    else
      if params[:q]
        collection = collection.where("api_key = '?'", params[:q])
      elsif params[:key] == "internal"
        collection = collection.where("api_key = '?'", ENV['API_KEY'])
      elsif params[:key] == "external"
        collection = collection.where("api_key != '?'", ENV['API_KEY'])
      elsif params[:key] == "other"
        collection = collection.where("ids LIKE ?", "Api::%")
      end
    end

    @api_requests = collection.order("created_at DESC").paginate(:page => params[:page])
  end
end
