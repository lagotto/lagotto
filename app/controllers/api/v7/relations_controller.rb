class Api::V7::RelationsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_work

  swagger_controller :relations, "Relations"

  swagger_api :index do
    summary "Returns list of relations for a particular work, source and/or relation_type"
    param :query, :work_id, :string, :optional, "Work ID"
    param :query, :work_ids, :string, :optional, "Work IDs"
    param :query, :q, :string, :optional, "Query for ids"
    param :query, :relation_type_id, :string, :optional, "Relation_type ID"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :recent, :integer, :optional, "Limit to relations created last x days"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    if @work
      collection = @work.inverse_relations
    else
      collection = Relation

      if params[:work_ids]
        work_ids = params[:work_ids].split(",")
        collection = collection.joins(:work).where(works: { "pid" => work_ids })
      end

      if params[:q]
        collection = collection.joins(:work).where("works.doi = ?", params[:q])
      end
    end

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = cached_source(params[:source_id])
      collection = collection.where(source_id: source.id)
    end

    collection = collection.joins(:related_work)

    if params[:recent]
      collection = collection.last_x_days(params[:recent].to_i)
    end

    @sources = @work.inverse_relations.where.not(source_id: nil).group(:source_id).count.reduce({}) do |sum, s|
      key = cached_source_names[s[0]]
      sum[key] = s[1]
      sum
    end

    @relation_types = @work.inverse_relations.where.not(relation_type_id: nil).group(:relation_type_id).count.reduce({}) do |sum, s|
      key = cached_relation_type_names[s[0]]
      sum[key] = s[1]
      sum
    end

    collection = collection.order("relations.updated_at DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    #total_entries = get_total_entries(params, source)

    collection = collection.paginate(per_page: per_page,
                                     page: page)

    @relations = collection.decorate
  end

  # use cached counts for total number of results
  def get_total_entries(params, source)
    case
    when params[:work_id] || params[:work_ids] || params[:q] || params[:relation_type] || params[:recent] then nil # can't be cached
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
    fail ActiveRecord::RecordNotFound unless @work.present?
  end
end
