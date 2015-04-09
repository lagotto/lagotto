class Api::V6::ReferencesController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :authenticate_user_from_token!, :load_work

  swagger_controller :related_works, "Related Works"

  swagger_api :index do
    summary "Returns list of works either by ID, or all"
    notes "If no ids are provided in the query, all works are returned, 1000 per page and sorted by publication date (default), or source event count. Search is not supported by the API."
    param :query, :ids, :string, :optional, "Work IDs"
    param :query, :q, :string, :optional, "Query for ids"
    param :query, :type, :string, :optional, "Work ID type (one of doi, pmid, pmcid, wos, scp, ark, or url)"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :publisher_id, :string, :optional, "Publisher ID"
    param :query, :sort, :string, :optional, "Sort by source event count descending, or by publication date descending if left empty."
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 500"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    collection = Relation.includes(:work, :related_work).where("work_id = ?", @work.id)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000

    collection = collection.paginate(per_page: per_page,
                                     page: params[:page])

    fresh_when last_modified: collection.maximum(:updated_at)

    @references = collection.decorate(context: { info: params[:info],
                                                    source_id: params[:source_id],
                                                    admin: current_user.try(:is_admin_or_staff?) })
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = get_id_hash(params[:work_id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      fail ActiveRecord::RecordNotFound
    end
  end
end
