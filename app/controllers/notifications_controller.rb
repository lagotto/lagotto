class NotificationsController < ApplicationController
  before_filter :load_notification, only: [:destroy]
  load_and_authorize_resource
  skip_authorize_resource :only => [:create, :routing_error]

  def index
    @servers = ENV['SERVERS'].split(",")

    collection = Notification
    if params[:source_id]
      collection = collection.includes(:source)
                   .where("sources.name = ?", params[:source_id])
                   .references(:source)
      @source = Source.where(name: params[:source_id]).first
    end

    if params[:hostname]
      collection = collection.where(:hostname => params[:hostname])
      @hostname = params[:hostname]
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

    @notifications = collection.paginate(page: (params[:page] || 1).to_i)
  end

  def create
    exception = env["action_dispatch.exception"]
    @notification = Notification.where(message: exception.message).where(unresolved: true).first_or_initialize(
      :exception => exception,
      :request => request)

    # Filter for errors that should not be saved
    if ["ActiveRecord::RecordNotFound",
        "ActionController::RoutingError",
        "CustomError::TooManyRequestsError"].include?(exception.class.to_s)
      @notification.status = request.headers["PATH_INFO"][1..-1]
    else
      @notification.save
    end

    respond_to do |format|
      format.json { render json: { error: @notification.public_message }, status: @notification.status }
      format.xml  { render xml: @notification.public_message, root: "error", status: @notification.status }
      format.html { render :show, status: @notification.status, layout: !request.xhr? }
      format.rss { render :show, status: @notification.status, layout: false }
    end
  end

  def destroy
    @servers = ENV['SERVERS'].split(",")
    if params[:filter] == "class_name"
      Notification.where(:class_name => @notification.class_name).update_all(:unresolved => false)
    elsif params[:filter] == "source_id"
      Notification.where(:source_id => @notification.source_id).update_all(:unresolved => false)
    elsif params[:filter] == "work_id"
      Notification.where(:work_id => @notification.work_id).update_all(:unresolved => false)
    else
      Notification.where(:message => @notification.message).update_all(:unresolved => false)
    end

    collection = Notification
    if params[:source_id]
      collection = collection.includes(:source)
                   .where("sources.name = ?", params[:source_id])
                   .references(:source)
      @source = Source.where(name: params[:source_id]).first
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    if params[:work_id]
      collection = collection.where(:work_id => params[:work_id])
      @work = Work.where(id: params[:work_id]).first
    end
    collection = collection.query(params[:q]) if params[:q]

    @notifications = collection.paginate(page: (params[:page] || 1).to_i)

    if params[:work_id]
      render :notification
    else
      render :index
    end
  end

  def routing_error
    fail ActiveRecord::RecordNotFound
  end

  protected

  def load_notification
    @notification = Notification.where(uuid: params[:id]).first

    # raise error if source wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @notification.blank?
  end
end
