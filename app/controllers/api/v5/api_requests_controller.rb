class Api::V5::ApiRequestsController < Api::V5::BaseController
  load_and_authorize_resource

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
