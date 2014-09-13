class Api::V3::ArticlesController < Api::V3::BaseController
  before_filter :load_article, :only => [:update, :destroy]

  def index
    # Filter by source parameter, filter out private sources unless admin
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    source_ids = get_source_ids(params[:source])

    type = { "doi" => :doi, "pmid" => :pmid, "pmcid" => :pmcid, "mendeley" => :mendeley_uuid }.values_at(params[:type]).first || Article.uid_as_sym

    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| Article.clean_id(id) }
    id_hash = { :articles => { type => ids }, :retrieval_statuses => { :source_id => source_ids }}
    @articles = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).order("articles.updated_at DESC").decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })

    # Return 404 HTTP status code and error message if article wasn't found, or no valid source specified
    if @articles.blank?
      if params[:source].blank?
        @error = "Article not found."
      else
        @error = "Source not found."
      end
      render "error", :status => :not_found
    end
  end

  def show
    # Load one article given query params
    source_ids = get_source_ids(params[:source])

    id_hash = { :articles => Article.from_uri(params[:id]), :retrieval_statuses => { :source_id => source_ids }}
    @article = ArticleDecorator.includes(:retrieval_statuses).where(id_hash).decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })

    # Return 404 HTTP status code and error message if article wasn't found, or no valid source specified
    if @article.blank?
      if params[:source].blank?
        @error = "Article not found."
      else
        @error = "Source not found."
      end
      render "error", :status => :not_found
    end
  end

  protected

  def load_article
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @article = Article.where(key => value).first
    else
      @article = nil
    end
  end

  # Filter by source parameter, filter out private sources unless admin
  def get_source_ids(source_names)
    if source_names && current_user.try(:is_admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif current_user.try(:is_admin_or_staff?)
      source_ids = Source.order("name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("name").pluck(:id)
    end
  end
end
