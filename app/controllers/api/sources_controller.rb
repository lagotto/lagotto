class Api::SourcesController < Api::BaseController
  def index
    collection = Source.active
    collection = collection.query(params[:q]) if params[:q]
    if params[:id].present?
      collection = collection.where(name: params[:id])
    end

    @sources = collection.order("title ASC")
    meta = { total: @sources.count }
    render json: @sources, meta: meta
  end

  def show
    source = Source.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless source.present?

    render json: source
  end
end
