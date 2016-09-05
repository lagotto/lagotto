class Api::V7::NotificationsController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  def index
    collection = Notification.unscoped.order("notifications.created_at DESC")
    collection = collection.where(unresolved: true) if params[:unresolved]
    if params[:source_id]
      collection = collection.joins(:source).where("sources.name = ?", params[:source_id])
      @source = Source.where(name: params[:source_id]).first
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    if params[:level]
      level = Notification::LEVELS.index(params[:level].upcase) || 0
      collection = collection.where("level = ?", level)
      @level = params[:level]
    end

    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.query(params[:q]) if params[:q]
    collection = collection.page(page)
    collection = collection.per_page(per_page)
    @notifications = collection.decorate
  end
end
