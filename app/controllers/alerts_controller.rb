class AlertsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:create, :routing_error]

  def index
    @servers = ENV['SERVERS'].split(",")

    collection = Alert
    if params[:source]
      collection = collection.includes(:source)
                   .where("sources.name = ?", params[:source])
                   .references(:source)
      @source = Source.where(name: params[:source]).first
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
    elsif params[:filter] == "article_id"
      Alert.where(:article_id => @alert.article_id).update_all(:unresolved => false)
    else
      Alert.where(:message => @alert.message).update_all(:unresolved => false)
    end

    collection = Alert
    if params[:source]
      collection = collection.includes(:source).where("sources.name = ?", params[:source])
      @source = Source.where(name: params[:source]).first
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    collection = collection.query(params[:q]) if params[:q]

    @alerts = collection.paginate(:page => params[:page])
    respond_with(@alerts) do |format|
      if params[:article_id]
        id_hash = Article.from_uri(params[:article_id])
        key, value = id_hash.first
        @article = Article.where(key => value).first
        format.js { render :alert }
      else
        format.js { render :index }
      end
    end
  end

  def routing_error
    redirect_to root_path, :alert => "The page you are looking for doesn't exist."
  end
end
