class Api::V4::AlertsController < Api::V4::BaseController
  load_and_authorize_resource

  def index
    collection = Alert.unscoped.order("alerts.created_at DESC")
    collection = collection.where(unresolved: true) if params[:unresolved]
    if params[:source]
      collection = collection.joins(:source).where("sources.name = ?", params[:source])
      @source = Source.where(name: params[:source]).first
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    if params[:level]
      level = Alert::LEVELS.index(params[:level].upcase) || 0
      collection = collection.where("level >= ?", level)
      @level = params[:level]
    end

    collection = collection.query(params[:q]) if params[:q]
    collection = collection.page(params[:page])
    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
    collection = collection.per_page(per_page)
    @alerts = collection.decorate
  end
end
