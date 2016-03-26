class RelationsController < ApplicationController
  # include helper module for query caching
  include Cacheable

  def index
    @page = params[:page] || 1
    @q = params[:q]
    @source = Source.for_aggregations.where(name: params[:source_id]).first
    @relation_type = cached_relation_type(params[:relation_type_id])
  end
end
