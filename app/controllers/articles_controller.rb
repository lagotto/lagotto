class ArticlesController < ApplicationController
  before_filter :detect_response_format, 
                :only => [ :show, :edit, :update, :destroy ]
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :load_article, 
                :only => [ :edit, :update, :destroy ]

  # GET /articles
  # GET /articles.xml
  def index
    @articles = Article.by(params[:order] || "doi")
    @articles = @articles.journal(params[:journal]) if params[:journal]
    @articles = @articles.cited if params[:cited]

    respond_to do |format|
      format.html { @articles = @articles.paginate(:page => params[:page]) }
      format.xml { render :xml => @articles }
      format.json { render_json @articles.to_json }
      format.csv do
        render :csv => @articles
      end
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    if params[:refresh] == "now"
      load_article
      Retriever.update(@article)
      redirect_to(@article) and return
    end
    load_article(eager_includes)
    format_options = {}
    format_options[:citations] = params[:citations]
    format_options[:history] = params[:history]
    format_options[:source] = params[:source]

    RetrievalWorker.async_retrieval(:article_id => @article.id) \
      if (params[:refresh] == "soon") or @article.stale?
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article.to_xml(format_options) }
      format.json  { render_json @article.to_json(format_options) }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to(@article) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to(@article) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end

protected
  def detect_response_format
    # Because dots are a valid part of our IDs, we have to manually
    # break off format specifiers (eg, ".json" or ".xml") here.
    id = params[:id]
    if id and id =~ %r/(.*)\.(json|xml)/i
      params[:id] = $1
      request.format = $2.downcase
    end
    true # keep processing..
  end

  def load_article(options={})
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi(doi, options) \
      or raise ActiveRecord::RecordNotFound
  end

  def eager_includes
    result = { :include => { :retrievals => [ :source ] } }
    if params[:citations] == "1"
      result[:include][:retrievals] << :citations
    end
    if params[:history] == "1"
      result[:include][:retrievals] << :histories
    end
    if params[:source]
      sources = params[:source].downcase.split(",")
      result[:conditions] = ['lower(sources.type) in (?)', sources]
    end
    result
  end

end
