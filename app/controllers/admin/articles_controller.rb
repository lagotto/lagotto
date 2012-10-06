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
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first
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
    id_hash = Article.from_uri(params[:id])
    if params[:source]
      @article = Article.where("#{id_hash.keys.first} = ? and lower(sources.name) in (?)", id_hash.values.first, params[:source].downcase.split(",")).
          includes(:retrieval_statuses => :source).first
    else
      @article = Article.where(id_hash).includes(:retrieval_statuses => :source).first
    end
    
    flash[:error] = "Couldn't find Article with #{id_hash.keys.first} = #{id_hash.values.first}" if @article.nil?
  end

end