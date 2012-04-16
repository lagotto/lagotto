
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index, :show ]

  respond_to :html, :xml, :json

  # GET /articles
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to doi)
    # source=source_type

    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page], :per_page => params[:per_page])
    @source = Source.find_by_name(params[:source].downcase) if params[:source]

    respond_with(@articles) do |format|
      format.json { render :json => @articles, :callback => params[:callback] }
      format.csv  { render :csv => @articles }
    end
  end

  # GET /articles/1
  def show

    load_article

    respond_with @article
  end

  # GET /articles/new
  def new
    @article = Article.new

    respond_with @article
  end

  # POST /articles
  def create
    @article = Article.new(params[:article])

    if @article.save
      flash[:notice] = 'Article was successfully created.'
    end
    respond_with(@article)
  end

  protected
  def load_article()
    # Load one article given query params, for the non-#index actions
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi)
  end
end
