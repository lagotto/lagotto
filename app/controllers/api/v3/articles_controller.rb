class Api::V3::ArticlesController < Api::V3::BaseController
  
  def index
    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page])
    
  end
  
  def show
    # Load one article given query params
    id_hash = Article.from_uri(params[:id])
    @article = Article.where(id_hash).first
    
    # Return 404 HTTP status code if article wasn't found
    render :status => 404 if @article.nil?
  end
  
end