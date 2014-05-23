class Api::V4::ArticlesController < Api::V4::BaseController
  # include article controller methods
  include Articable

  before_filter :load_article, :only => [ :update, :destroy ]
  # load_and_authorize_resource :except => [ :show, :index ]

  def show
    # Load one article given query params
    source_ids = get_source_ids(params[:source])

    id_hash = { :articles => Article.from_uri(params[:id]), :retrieval_statuses => { :source_id => source_ids }}
    @article = ArticleDecorator.includes(:retrieval_statuses).where(id_hash).decorate(context: { info: params[:info], source: params[:source] })

    # Return 404 HTTP status code and error message if article wasn't found, or no valid source specified
    if @article.blank?
      if params[:source].blank?
        @error = "Article not found."
      else
        @error = "Source not found."
      end
      render :status => :not_found
      render "error"
    else
      @success = "Article found."
    end
  end

  def create
    @article = Article.new(safe_params)
    authorize! :create, @article

    if @article.save
      @success = "Article created."
      render :status => :created
      render "success"
    else
      @error = @article.errors
      render :status => :created
      render "error"
    end
  end

  def update
    authorize! :update, @article

    if @article.blank?
      @error = "No article found."
      render :status => :not_found
      render "error"
    elsif @article.update_attributes(safe_params)
      @success = "Article updated."
      render :status => :ok
      render "success"
    else
      @error = @article.errors
      render :status => :bad_request
      render "error"
    end
  end

  def destroy
    authorize! :destroy, @article

    if @article.blank?
      @error = "No article found."
      render :status => :not_found
      render "error"
    elsif @article.destroy
      @success = "Article deleted."
      render :status => :ok
      render "success"
    else
      @error = "An error occured."
      render :status => :bad_request
      render "error"
    end
  end
end
