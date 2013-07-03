class Api::V3::ArticlesController < Api::V3::BaseController
  before_filter :load_article, :only => [ :update, :destroy ]
  load_and_authorize_resource :except => :show

  def index
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    type = { "doi" => "doi", "pmid" => "pub_med", "pmcid" => "pub_med_central", "mendeley" => "mendeley" }.assoc(params[:type])
    type = type.nil? ? Article.uid : type[1]
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| Article.clean_id(id) }
    id_hash = { type.to_sym => ids }
    
    if params[:source]
      source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("name").pluck(:id)
      id_hash = { :articles => id_hash, :retrieval_statuses => { :source_id => source_ids } }
    end
    
if current_user.try(:admin?)
    
    @articles = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).order("articles.updated_at DESC").decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
    
    # Return 404 HTTP status code and error message if article wasn't found
    if @articles.blank?
      @error = "No article found."
      render "error", :status => :not_found 
    end
  end
  
  def show
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])

    if params[:source]
      source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("name").pluck(:id)
      id_hash = { :articles => id_hash, :retrieval_statuses => { :source_id => source_ids } }
    end
    
    @article = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })

    # Return 404 HTTP status code and error message if article wasn't found
    if @article.blank?
      @error = "No article found."
      render "error", :status => :not_found 
    end
  end

  def create
    @article = Article.new(params[:article])

    if @article.save
      @success = "Article created."
      @article = params[:article]
      render "success", :status => :created
    else
      @error = @article.errors
      @article = params[:article]
      render "error", :status => :bad_request
    end
  end

  def update
    if @article.blank?
      @error = "No article found."
      @article = @id_hash
      render "error", :status => :not_found 
    elsif @article.update_attributes(params[:article])
      @success = "Article updated."
      @article = @id_hash
      render "success", :status => :ok
    else
      @error = @article.errors
      @article = @id_hash
      render "error", :status => :bad_request
    end
  end

  def destroy
    if @article.blank?
      @error = "No article found."
      @article = @id_hash
      render "error", :status => :not_found 
    elsif @article.destroy
      @success = "Article deleted."
      @article = @id_hash
      render "success", :status => :ok
    else
      @error = "An error occured."
      @article = @id_hash
      render "error", :status => :bad_request
    end
  end

  protected
  def load_article
    # Load one article given query params
    @id_hash = Article.from_uri(params[:id])
    @article = Article.where(@id_hash).first
  end
end