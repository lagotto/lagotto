class Admin::ArticlesController < Admin::ApplicationController
  before_filter :load_article, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    load_index
    respond_with do |format|
      format.js { render :index }
    end
  end

  def show
    @api_key = APP_CONFIG['api_key']

    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # GET /articles/new
  def new
    load_index
    @article = Article.new
    respond_with(@article) do |format|
      format.js { render :index }
    end
  end

  # POST /articles
  def create
    load_index
    @article = Article.new(params[:article])
    @article.save
    respond_with(@article) do |format|
      format.js { render :index }
    end
  end

  # GET /articles/:id/edit
  def edit
    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # PUT /articles/:id(.:format)
  def update
    @article.update_attributes(params[:article])
    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # DELETE /articles/:id(.:format)
  def destroy
    @article.destroy
    redirect_to articles_path
  end

  protected
  def load_article()
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first

    # raise error if article wasn't found
    raise ActiveRecord::RecordNotFound.new if @article.blank?
  end

  def load_index
    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    if params[:class_name]
      @class_name = params[:class_name]
      collection = collection.includes(:alerts)
      if @class_name == "All Alerts"
        collection = collection.where("alerts.unresolved = ?", true) #collection.where("alerts.unresolved = 1")
      else
        collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name) #collection.where("alerts.unresolved = 1 AND alerts.class_name = ?", @class_name)
      end
    end
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page])

    if params[:source]
      @sources = Source.where("lower(name) in (?)", params[:source].split(",")).order("name")
    else
      @sources = Source.order("name")
    end
  end
end
