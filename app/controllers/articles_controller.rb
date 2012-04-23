
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

    if params[:refresh] == "1"
      @article.update_data_from_sources
      redirect_to(@article) and return
    end

    format_options = params.slice :citations, :history, :source

    respond_with(@article) do |format|
      format.csv  { render :csv => @article }
      format.json { render :json => @article.as_json(format_options), :callback => params[:callback] }
      format.xml  do
        response.headers['Content-Disposition'] = 'attachment; filename=' + params[:id].sub(/^info:/,'') + '.xml'
        render :xml => @article.to_xml(:citations => format_options[:citations],
                                       :history => format_options[:history],
                                       :source => format_options[:source])
      end
    end
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

  # GET /articles/:id/edit
  def edit
    load_article
  end

  # PUT /articles/:id(.:format)
  def update
    load_article
    if @article.update_attributes(params[:article])
      flash[:notice] = 'Article was successfully updated.'
    end
    respond_with(@article)
  end

  # DELETE /articles/:id(.:format)
  def destroy
    load_article
    @article.destroy
    flash[:notice] = 'Article was successfully deleted.'
    respond_with(@article)
  end

  protected
  def load_article()
    # Load one article given query params, for the non-#index actions
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi)
  end
end
