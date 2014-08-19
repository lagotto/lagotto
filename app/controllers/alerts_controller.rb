class AlertsController < ActionController::Base
  load_and_authorize_resource
  skip_authorize_resource :only => [:create]

  layout 'application'

  respond_to :html, :xml, :json, :rss

  def index
    collection = Alert
    if params[:source]
      collection = collection.includes(:source).where("sources.name = ?", params[:source])
      @source = Source.find_by_name(params[:source])
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    if params[:level]
      collection = collection.where("level >= ?", params[:level])
      @level = params[:level] || 1
    end
    collection = collection.query(params[:q]) if params[:q]

    @alerts = collection.paginate(:page => params[:page])
    respond_with @alerts
  end

  def create
    exception = env["action_dispatch.exception"]
    @alert = Alert.new(:exception => exception, :request => request)

    # Filter for errors that should not be saved
    unless["ActiveRecord::RecordNotFound", "ActionController::RoutingError"].include?(exception.class.to_s)
      @alert.save
    else
      @alert.status = request.headers["PATH_INFO"][1..-1]
    end

    respond_with(@alert) do |format|
      format.json { render json: { error: @alert.public_message }, status: @alert.status }
      format.xml  { render xml: @alert.public_message, root: "error", status: @alert.status }
      format.html { render :show, status: @alert.status, layout: !request.xhr? }
      format.rss { render :show, status: @alert.status, layout: false }
    end
  end

  def destroy
    @alert = Alert.find(params[:id])
    if params[:filter] == "class_name"
      Alert.where(:class_name => @alert.class_name).update_all(:unresolved => false)
    elsif params[:filter] == "source_id"
      Alert.where(:source_id => @alert.source_id).update_all(:unresolved => false)
    elsif params[:filter] == "article_id"
      Alert.where(:article_id => @alert.article_id).update_all(:unresolved => false)
    else
      Alert.where(:message => @alert.message).update_all(:unresolved => false)
    end

    collection = Alert
    if params[:source]
      collection = collection.includes(:source).where("sources.name = ?", params[:source])
      @source = Source.find_by_name(params[:source])
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
end

