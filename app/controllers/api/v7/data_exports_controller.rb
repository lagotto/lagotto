class Api::V7::DataExportsController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  PER_PAGE = 1000

  swagger_controller :data_exports, "DataExports"

  swagger_api :index do
    summary "Returns data exports in order of the most recent exports first"
    # notes "If no work ids or source names are provided in the query, all events are returned, 1000 per page and sorted by update date."
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page, defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    collection = DataExport.all.order("id DESC")
    per_page = params[:per_page] && (0..PER_PAGE).include?(params[:per_page].to_i) ? params[:per_page].to_i : PER_PAGE
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page, :page => page)

    @data_exports = collection.decorate
  end
end
