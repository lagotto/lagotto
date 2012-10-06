class Api::V3::ArticlesController < Api::V3::BaseController
  
  def index
    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.query(params[:query])  if params[:query]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page])
    
  end
  
  def show
    
    begin 
      doi = DOI::from_uri(params[:id])
      @article = Article.find_by_doi!(doi)
    rescue ActiveRecord::RecordNotFound
      # Return 404 HTTP status code if article isn't found
      @article = nil
      render :status => 404
    end
    
  end
  
end