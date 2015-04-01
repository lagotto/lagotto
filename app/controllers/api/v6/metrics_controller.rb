class Api::V6::MetricsController < Api::BaseController
  before_filter :authenticate_user_from_token!

  swagger_controller :metrics, "Metrics"

  swagger_api :index do
    summary "Returns list of metrics by work IDs and/or source names"
    notes "If no work ids or source names are provided in the query, all metrics are returned, 1000 per page and sorted by update date."
    param :query, :work_ids, :string, :optional, "Work IDs"
    param :query, :source_ids, :string, :optional, "Source names"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page, defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    collection = RetrievalStatus

    if params[:work_ids]
      collection = collection.joins(:work).where("works.pid IN (?)", params[:work_ids])
    end

    if params[:source_ids]
      collection = collection.joins(:source).where("sources.name IN (?)", params[:source_ids])
    end

    if params[:order]
      order = ["pdf", "html", "readers", "comments", "likes", "total"].find { |t| t == params[:order] } || "total"
      collection = collection.order("? DESC", order)
    else
      collection = collection.order("retrieval_statuses.updated_at DESC")
    end

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    collection = collection.paginate(per_page: per_page, :page => params[:page])

    fresh_when last_modified: collection.maximum(:updated_at)

    @retrieval_statuses = collection.decorate
  end
end
