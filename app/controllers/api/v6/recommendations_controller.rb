class Api::V6::RecommendationsController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_action :load_work

  swagger_controller :recommendations, "Recommendations"

  swagger_api :index do
    summary "Returns list of recommendations given a work, optionally filtered by relation_type and/or source"
    param :query, :work_id, :string, :required, "Work ID"
    param :query, :relation_type_id, :string, :optional, "Relation_type ID"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    related_work_ids = @work.reference_relations.pluck(:related_work_id)
    relation_type_ids = RelationType.where("name = 'is_cited_by' OR name = 'is_bookmarked_by' OR name = 'is_referenced_by'").pluck(:id)
    collection = Relation.referencable.where.not(work_id: @work.id)
                                      .where(related_work_id: related_work_ids)
                                      .where(relation_type_id: relation_type_ids)

    if params[:relation_type_id] && relation_type = RelationType.where(name: params[:relation_type_id]).first
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: source.id)
    end

    collection = collection.includes(:work).order("works.published_on DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000

    collection = collection.paginate(per_page: per_page, page: params[:page])

    @recommendations = collection.decorate
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
