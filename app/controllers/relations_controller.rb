class RelationsController < ApplicationController
  # include helper module for query caching
  include Cacheable

  def index
    collection = Relation.includes(:work, :related_work)

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: source.id)
    end

    collection = collection.order("relations.updated_at DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000

    @relations = collection.paginate(per_page: per_page, page: params[:page])

    @page = params[:page] || 1
    @q = params[:q]
    @source = Source.active.where(name: params[:source_id]).first
    @relation_type = cached_relation_type(params[:relation_type_id])
  end
end
