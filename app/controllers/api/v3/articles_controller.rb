class Api::V3::ArticlesController < Api::V3::BaseController
  before_filter :load_article, :only => [ :update, :destroy ]
  #load_and_authorize_resource :except => [ :show, :index ]

  def index
    # Filter by source parameter, filter out private sources unless admin
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    source_ids = get_source_ids(params[:source])

    type = { "doi" => "doi", "pmid" => "pub_med", "pmcid" => "pub_med_central", "mendeley" => "mendeley" }.assoc(params[:type])
    type = type.nil? ? Article.uid : type[1]
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| Article.clean_id(id) }
    id_hash = { :articles => { type.to_sym => ids }, :retrieval_statuses => { :source_id => source_ids }}
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
    @id_hash = Article.from_uri(params[:id])
    @article = Article.where(@id_hash).first
  end

  # Filter by source parameter, filter out private sources unless admin
  def get_source_ids(source_names)
    if source_names and current_user.try(:admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)  #where("private = 0")
    elsif current_user.try(:admin_or_staff?)
      source_ids = Source.order("name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("name").pluck(:id)  #where("private = 0")
    end
  end
end