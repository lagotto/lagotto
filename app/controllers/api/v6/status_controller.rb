class Api::V6::StatusController < Api::BaseController
  before_filter :authenticate_user_from_token!

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

    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = Status.all.order("created_at DESC").paginate(:page => page)
    @status = collection.decorate(context: { role: is_admin_or_staff? })
  end
end
