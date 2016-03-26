class ContributionsController < ApplicationController
  # include helper module for query caching
  include Cacheable

  def index
    @page = params[:page] || 1
    @q = params[:q]
    @source = Source.for_aggregations.where(name: params[:source_id]).first
    @contributor_role = cached_contributor_role(params[:contributor_role_id])
  end
end
