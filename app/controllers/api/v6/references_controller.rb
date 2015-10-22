class Api::V6::ReferencesController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :authenticate_user_from_token!, :load_work

  swagger_controller :references, "References"

  swagger_api :index do
    summary "Returns list of references for a particular work, source and/or relation_type"
    param :query, :work_id, :string, :optional, "Work ID"
    param :query, :work_ids, :string, :optional, "Work IDs"
    param :query, :q, :string, :optional, "Query for ids"
    param :query, :relation_type_id, :string, :optional, "Relation_type ID"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :recent, :integer, :optional, "Limit to references created last x days"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    if @work
      collection = @work.reference_relations
    else
      collection = Relation.referencable
    end

    if params[:work_ids]
      work_ids = params[:work_ids].split(",")
      collection = collection.joins(:work).where(works: { "pid" => work_ids })
    end

    if params[:q]
      collection = collection.joins(:work).where("works.pid like ?", "#{params[:q]}%")
    end

    if params[:relation_type_id] && relation_type = RelationType.where(name: params[:relation_type_id]).first
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: source.id)
    end

    collection = collection.includes(:related_work)

    if params[:recent]
      collection = collection.last_x_days(params[:recent].to_i)
    end

    if params[:sort] == "created_at"
      collection = collection.order("works.created_at ASC")
    else
      collection = collection.order("works.published_on DESC")
    end

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:per_page].to_i > 0 ? params[:page].to_i : 1
    total_entries = get_total_entries(params, source)

    collection = collection.paginate(per_page: per_page,
                                     page: page,
                                     total_entries: total_entries)

    @reference_relations = collection.decorate
  end

  # use cached counts for total number of results
  def get_total_entries(params, source)
    case
    when params[:work_ids] || params[:q] || params[:relation_type] || params[:recent] then nil # can't be cached
    when source then source.relation_count
    else Relation.count_all
    end
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
