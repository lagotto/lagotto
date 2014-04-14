class Admin::ArticlesController < Admin::ApplicationController
  before_filter :load_article, :only => [ :show, :edit, :update, :destroy ]
  before_filter :new_article, :only => [:create]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    respond_with do |format|
      format.js { render "admin/articles/index" }
      format.html { redirect_to articles_path }
    end
  end

  def show
    @api_key = CONFIG[:api_key]

    respond_with(@article) do |format|
      format.js { render :show }
    end
  end

  # GET /articles/new
  def new
    @article = Article.new(day: Date.today.day, month: Date.today.month, year: Date.today.year)
    respond_with(@article) do |format|
      format.js { render :index }
    end
  end

  # POST /articles
  def create
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
    @article.update_attributes(safe_params)
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

  def load_article
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first

    # raise error if article wasn't found
    fail ActiveRecord::RecordNotFound if @article.blank?
  end

  def new_article
    @article = Article.new(safe_params)
  end

  private

  def safe_params
    params.require(:article).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
  end
end
