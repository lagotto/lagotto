class Api::V6::WorksController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  prepend_before_action :load_work, only: [:show, :update, :destroy]
  before_action :authenticate_user_from_token!

  swagger_controller :works, "Works"

  swagger_api :index do
    summary "Returns list of works either by ID, or all"
    notes "If no ids are provided in the query, all works are returned, 1000 per page and sorted by publication date (default), or source event count. Search is not supported by the API."
    param :query, :ids, :string, :optional, "Work IDs"
    param :query, :q, :string, :optional, "Query for ids"
    param :query, :type, :string, :optional, "Work ID type (one of doi, pmid, pmcid, arxiv, wos, scp, ark, or url)"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :publisher_id, :string, :optional, "Publisher ID"
    param :query, :sort, :string, :optional, "Sort by source event count descending, by works created at date/time, or by publication date descending if left empty."
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  swagger_api :show do
    summary "Show a work"
    param :path, :id, :string, :required, "Work ID"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  swagger_api :create do
    summary "Create a work"
    notes "Authentication via API key is required"
    param :work, :type, :hash, :required, "Work ID type (one of doi, pmid, pmcid, arxiv, wos, scp, ark, dataone, or url)"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  swagger_api :update do
    summary "Update a work"
    notes "Authentication via API key is required"
    param :path, :id, :string, :required, "Work ID"
    param :work, :type, :hash, :required, "Work ID type (one of doi, pmid, pmcid, arxiv, wos, scp, ark, dataone, or url)"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  swagger_api :destroy do
    summary "Delete a work"
    notes "Authentication via API key is required"
    param :path, :id, :string, :required, "Work ID"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def show
    @work = @work.decorate(context: { role: is_admin_or_staff? })

    fresh_when last_modified: @work.updated_at
  end

  def index
    source = Source.where(name: params[:source_id]).first
    publisher = Publisher.where(name: params[:publisher_id]).first

    collection = get_ids(params)
    collection = get_class_name(collection, params) if params[:class_name]
    collection = get_sort(collection, params, source)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    total_entries = get_total_entries(params, source, publisher)

    collection = collection.paginate(per_page: per_page,
                                     page: params[:page],
                                     total_entries: total_entries)

    @works = collection.decorate(context: { role: is_admin_or_staff? })
    arr = Work::Metrics.load_for_works(@works.map(&:object))
  end

  def create
    @work = Work.new(safe_params)
    authorize! :create, @work

    if @work.save
      @status = "created"
      @work = @work.decorate
      render "show", :status => :created
    else
      render json: { meta: { status: "error", error: @work.errors }, work: {}}, status: :bad_request
    end
  end

  def update
    authorize! :update, @work

    if @work.update_attributes(safe_params)
      @work = @work.decorate

      @status = "updated"
      render "show", :status => :ok
    else
      render json: { meta: { status: "error", error: @work.errors }, work: {}}, status: :bad_request
    end
  end

  def destroy
    authorize! :destroy, @work

    if @work.destroy
      render json: { meta: { status: "deleted" }, work: {} }, status: :ok
    else
      render json: { meta: { status: "error", error: "An error occured." }, work: {}}, status: :bad_request
    end
  end

  # Load works from ids listed in query string, use type parameter if present
  # Translate type query parameter into column name
  def get_ids(params)
    if params[:ids]
      type = ["doi", "pmid", "pmcid", "arxiv", "wos", "scp", "ark", "dataone", "url"].find { |t| t == params[:type] } || "pid"
      type = "canonical_url" if type == "url"
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| get_clean_id(id) }
      collection = Work.where(works: { type => ids })
    elsif params[:q]
      collection = Work.query(params[:q])
    elsif params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = Work.joins(:retrieval_statuses)
                   .where("retrieval_statuses.source_id = ?", source.id)
                   .where("retrieval_statuses.total > 0")
    elsif params[:publisher_id] && publisher = Publisher.where(name: params[:publisher_id]).first
      collection = Work.where(publisher_id: publisher.member_id)
    else
      collection = Work.tracked
    end
  end

  def get_class_name(collection, params)
    @class_name = params[:class_name]
    collection = collection.includes(:alerts).references(:alerts)
    if @class_name == "All Alerts"
      collection = collection.where("alerts.unresolved = ?", true)
    else
      collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
    end
  end

  # sort by source total
  # we can't filter and sort by two different sources
  def get_sort(collection, params, source)
    if params[:sort] && source && params[:sort] == params[:source_id]
      collection = collection.order("retrieval_statuses.total DESC")
    elsif params[:sort] && !source && sort = Source.where(name: params[:sort]).first
      collection = collection.joins(:retrieval_statuses)
        .where("retrieval_statuses.source_id = ?", sort.id)
        .order("retrieval_statuses.total DESC")
    elsif params[:sort] == "created_at"
      collection.order("works.created_at ASC")
    else
      collection.order("works.published_on DESC")
    end
  end

  # use cached counts for total number of results
  def get_total_entries(params, source, publisher)
    case
    when params[:ids] || params[:q] || params[:class_name] then nil # can't be cached
    when source && publisher then publisher.work_count_by_source(source.id)
    when source then source.work_count
    when publisher then publisher.work_count
    else Work.count_all
    end
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :canonical_url, :arxiv, :wos, :scp, :ark, :dataone, :publisher_id, :year, :month, :day, :tracked)
  end
end
