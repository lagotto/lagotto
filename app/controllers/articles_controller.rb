class ArticlesController < ApplicationController
  before_filter :detect_response_format, 
                :only => [ :show, :edit, :update, :destroy ]
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :load_article, 
                :only => [ :edit, :update, :destroy ]

  # GET /articles
  # GET /articles.xml
  def index
    respond_to do |format|
      format.html { load_articles(:paginate => true) }
      format.xml { render :xml => load_articles }
      format.json { render_json load_articles.to_json }
      format.csv do
        load_articles
        if params[:source]
          @source = Source.find_by_name(params[:source])
          render :action => "index_for_source"
        else
          render :csv => @articles
        end
      end
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    if params[:refresh] == "now"
      load_article
      Retriever.new(:lazy => false, :forceNow => true, :only_source => false).update(@article)      
      redirect_to(@article) and return
    end
    load_article(eager_includes)
    format_options = {}
    format_options[:citations] = params[:citations]
    format_options[:history] = params[:history]
    format_options[:source] = params[:source]

    if (params[:refresh] == "soon" or @article.stale?)
      RAILS_DEFAULT_LOGGER.info "Queuing article #{@article.id} for retrieval"
      RetrievalWorker.async_retrieval(:article_id => @article.id) 
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  {
        response.headers['Content-Disposition'] = 'attachment; filename=' + params[:id].sub(/^info:/,'') + '.xml'
        render :xml => @article.to_xml(format_options)
      }
      format.csv  { render :csv => @article }
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

    article = @article.save
    
    respond_to do |format|
      if article
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to(@article) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
    
    Source.all.each do |source|
      retrieval = Retrieval.find_or_create_by_article_id_and_source_id(article.id, source.id)
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
    # break off format specifiers (eg, ".json", ".xml" or ".csv") here.
    id = params[:id]
    if id and id =~ %r/(.*)\.(json|xml|csv)/i
      params[:id] = $1
      request.format = $2.downcase
    end
    true # keep processing..
  end

  def load_articles(options={})
    # Load articles given query params, for #index
    @articles, @article_count = Article.load_articles(params, options)
  end

  def load_article(options={})
    # Load one article given query params, for the non-#index actions
    @article = Article.load_article(params, options)
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
      result[:conditions] = ['lower(sources.name) in (?)', sources]
    end
    result
  end

end
