class Api::V3::ArticlesController < Api::V3::BaseController
  
  def index
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 100
    type = { "doi" => "doi", "pmid" => "pub_med", "pmcid" => "pub_med_central", "mendeley" => "mendeley" }.assoc(params[:type])
    type = type.nil? ? Article.uid : type[1]
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...100].map { |id| Article.clean_id(id) }
    
    @articles = Article.where(type.to_sym => ids)
    
    # Return 404 HTTP status code and error message if article wasn't found
    render "404", :status => 404 if @articles.blank?
  end
  
  def show
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first
    
    # Return 404 HTTP status code and error message if article wasn't found
    render "404", :status => 404 if @article.blank?
  end
  
end