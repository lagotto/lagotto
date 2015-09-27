class Api::V6::NotificationsController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  swagger_controller :notifications, "Notifications"

  swagger_api :index do
    summary "Returns all API notifications"
    notes "Authentication with a valid API key with staff or admin permissions is required."
    param :query, :unresolved, :boolean, :optional, "Return only unresolved notifications"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :class_name, :string, :optional, "Class name of notification"
    param :query, :level, :integer, :optional, "Error level"
    param :query, :q, :string, :optional, "Query message or class name"
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :unauthorized
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

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
      collection = collection.where("level >= ?", level)
      @level = params[:level]
    end

    collection = collection.query(params[:q]) if params[:q]
    collection = collection.page(params[:page])
    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
    collection = collection.per_page(per_page)
    @notifications = collection.decorate
  end
end
