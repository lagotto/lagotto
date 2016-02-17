class Api::V6::EventsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_work

  swagger_controller :events, "Events"

  swagger_api :index do
    summary "Returns event counts by work IDs and/or source names"
    notes "If no work ids or source names are provided in the query, all events are returned, 1000 per page and sorted by update date."
    param :query, :work_id, :string, :optional, "Work ID"
    param :query, :work_ids, :string, :optional, "Work IDs"
    param :query, :source_id, :string, :optional, "Source name"
    param :query, :sort, :string, :optional, "Sort by event count (pdf, html, readers, comments, likes or total) descending, or by update date descending if left empty."
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page, defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    if @work
      collection = @work.events
    elsif params[:work_ids]
      work_ids = params[:work_ids].split(",")
      collection = Event.joins(:work).where(works: { "pid" => work_ids })
    elsif params[:source_id]
      collection = Event.joins(:source).where("sources.name = ?", params[:source_id])
    elsif params[:publisher_id]
      collection = Event.joins(:work).where("works.publisher_id = ?", params[:publisher_id])
    else
      collection = Event
    end

    collection = collection.joins(:source).where("private <= ?", is_admin_or_staff?)

    if params[:sort]
      sort = ["pdf", "html", "readers", "comments", "likes", "total"].include?(params[:sort]) ? params[:sort] : "total"
      collection = collection.order(sort.to_sym => :desc)
    else
      collection = collection.order("events.updated_at DESC")
    end

    collection = collection.includes(:work, :source, :months)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page, :page => page)

    @events = collection.decorate
  end

  protected

  def load_work
    return nil unless params[:work_id].present?

    id_hash = get_id_hash(params[:work_id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
  end
end
