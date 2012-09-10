class Admin::ArticlesController < Admin::ApplicationController
  
  # GET /articles/new
  def new
    @article = Article.new
  end

  # POST /articles
  def create
    @article = Article.new(params[:article])
    flash[:notice] = 'Article was successfully created.' if @article.save
    redirect_to admin_root_path
  end

  # GET /articles/:id/edit
  def edit
    load_article
    redirect_to admin_root_path
  end

  # PUT /articles/:id(.:format)
  def update
    load_article
    flash[:notice] = 'Article was successfully updated.' if @article.update_attributes(params[:article])   
    respond_with(@article)
  end

  # DELETE /articles/:id(.:format)
  def destroy
    load_article
    @article.destroy
    flash[:notice] = 'Article was successfully deleted.'
    respond_with(@articles)
  end
  
  protected
  def load_article()
    # Load one article given query params
    doi = DOI::from_uri(params[:id])
    @article = Article.find_by_doi!(doi)
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