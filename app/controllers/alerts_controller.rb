class AlertsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:create, :routing_error]

  def index
    @servers = ENV['SERVERS'].split(",")

    collection = Alert
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
      level = Alert::LEVELS.index(params[:level].upcase) || 0
      collection = collection.where("level >= ?", level)
      @level = params[:level]
    end

    collection = collection.query(params[:q]) if params[:q]

    @alerts = collection.paginate(:page => params[:page])
    respond_with @alerts
  end

  def create
    exception = env["action_dispatch.exception"]
    @alert = Alert.new(:exception => exception, :request => request)

    # Filter for errors that should not be saved
    if ["ActiveRecord::RecordNotFound", "ActionController::RoutingError"].include?(exception.class.to_s)
      @alert.status = request.headers["PATH_INFO"][1..-1]
    else
      @alert.save
    end

    respond_with(@alert) do |format|
      format.json { render json: { error: @alert.public_message }, status: @alert.status }
      format.xml  { render xml: @alert.public_message, root: "error", status: @alert.status }
      format.html { render :show, status: @alert.status, layout: !request.xhr? }
      format.rss { render :show, status: @alert.status, layout: false }
    end
  end

  def destroy
    @servers = ENV['SERVERS'].split(",")
    @alert = Alert.find(params[:id])
    if params[:filter] == "class_name"
      Alert.where(:class_name => @alert.class_name).update_all(:unresolved => false)
    elsif params[:filter] == "source"
      Alert.where(:source_id => @alert.source_id).update_all(:unresolved => false)
    elsif params[:filter] == "work_id"
      Alert.where(:work_id => @alert.work_id).update_all(:unresolved => false)
    else
      Alert.where(:message => @alert.message).update_all(:unresolved => false)
    end

    collection = Alert
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

    @alerts = collection.paginate(:page => params[:page])
    respond_with(@alerts) do |format|
      if params[:work_id]
        format.js { render :alert }
      else
        format.js { render :index }
      end
    end
  end

  def routing_error
    @alert = Alert.new(message: "The page you are looking for doesn't exist.", status: 404)
    render "alerts/show", status: 404
  end
end
