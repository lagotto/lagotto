class Api::V3::ArticlesController < Api::V3::BaseController
  
  def index
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    type = { "doi" => "doi", "pmid" => "pub_med", "pmcid" => "pub_med_central", "mendeley" => "mendeley" }.assoc(params[:type])
    type = type.nil? ? Article.uid : type[1]
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| Article.clean_id(id) }
    id_hash = { type.to_sym => ids }
    
    if params[:source]
      source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("name").pluck(:id)
      id_hash = { :articles => id_hash, :retrieval_statuses => { :source_id => source_ids } }
    end
    
    @articles = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).order("articles.updated_at DESC").decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
    
    # Return 404 HTTP status code and error message if article wasn't found
    render "404", :status => 404 if @articles.blank?
  end
  
  def show
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    
    if params[:source]
      source_ids = Source.where("lower(name) in (?)", params[:source].split(",")).order("name").pluck(:id)
      id_hash = { :articles => id_hash, :retrieval_statuses => { :source_id => source_ids } }
    end
    
    @article = ArticleDecorator.where(id_hash).includes(:retrieval_statuses).decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
    
    # Return 404 HTTP status code and error message if article wasn't found
    render "404", :status => 404 if @article.blank?
  end
  
end