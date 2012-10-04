class Admin::ArticlesController < Admin::ApplicationController
  
  respond_to :html, :js
  
  def index
    load_index
    respond_with do |format|  
      format.js { render :index }
    end
  end
  
  def show
    load_article
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
    load_article
    respond_with(@article) do |format|  
      format.js { render :show }
    end
  end

  # PUT /articles/:id(.:format)
  def update
    load_article
    @article.update_attributes(params[:article])   
    respond_with(@article) do |format|  
      format.js { render :show }
    end
  end

  # DELETE /articles/:id(.:format)
  def destroy
    load_article
    @article.destroy
    redirect_to articles_path
  end
  
  protected
  def load_article()
    # Load one article given query params
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi)
  end
  
  def load_index
    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page])

    # source url parameter is only used for csv format
    @source = Source.find_by_name(params[:source].downcase) if params[:source]

    if params[:source]
      @sources = Source.where("lower(name) in (?)", params[:source].split(",")).order("display_name")
    else
      @sources = Source.order("display_name")
    end
  end

  def load_article_eager_includes
    doi = DOI::from_uri(params[:id])
    if params[:source]
      @article = Article.where("doi = ? and lower(sources.name) in (?)", doi, params[:source].downcase.split(",")).
          includes(:retrieval_statuses => :source).first
    else
      @article = Article.where("doi = ?", doi).includes(:retrieval_statuses => :source).first
    end

    raise ActiveRecord::RecordNotFound, "Couldn't find Article with doi = #{doi}" if @article.nil?
  end
end