class Api::V5::StatusController < Api::V5::BaseController
  swagger_controller :status, "Status"

  swagger_api :index do
    summary "Returns status information"
    notes "Status information is generated every hour. Returns 1,000 results per page."
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    Status.create unless Status.count > 0

    collection = Status.all
    @status = collection.order("created_at DESC").paginate(:page => params[:page])

    @user = current_user ? current_user.cache_key : "2"
  end
end
