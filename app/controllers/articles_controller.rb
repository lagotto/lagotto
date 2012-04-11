
class ArticlesController < ApplicationController

  # GET /articles
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to doi)
    # source=source_type

    collection = Article
    collection = collection.cited(params[:cited])  if params[:cited]
    collection = collection.order_articles(params[:order])

    @articles = collection.paginate(:page => params[:page], :per_page => params[:per_page])
    @source = Source.find_by_name(params[:source].downcase) if params[:source]

    respond_to do |format|
      format.html
      format.xml  { render :xml => @articles }
      format.json { render :json => @articles, :callback => params[:callback] }
      format.csv  { render :csv => @articles }
    end
  end

end
