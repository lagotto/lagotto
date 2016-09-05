class Api::V7::RecommendationsController < Api::BaseController
  before_filter :load_work

  def index
    related_work_ids = @work.relations.pluck(:related_work_id)
    relation_type_ids = @work.relation_types_for_recommendations

    collection = Relation.where.not(work_id: @work.id)
                         .where(related_work_id: related_work_ids)
                         .where(relation_type_id: relation_type_ids)

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: source.id)
    end

    collection = collection.includes(:work).order("works.published_on DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1

    collection = collection.paginate(per_page: per_page, page: page)

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
