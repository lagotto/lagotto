class Admin::AlertsController < Admin::ApplicationController
  load_and_authorize_resource

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
    collection = collection.query(params[:q]) if params[:q]

    @alerts = collection.paginate(:page => params[:page].to_i)
    respond_with @alerts
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

    @alerts = collection.paginate(:page => params[:page].to_i)
    respond_with(@alerts) do |format|
      if params[:article_id]
        id_hash = Article.from_uri(params[:article_id])
        @article = Article.where(id_hash).first
        format.js { render :alert }
      else
        format.js { render :index }
      end
    end
  end
end
