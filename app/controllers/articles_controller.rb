
class ArticlesController < ApplicationController

  # GET /articles
  # GET /articles.xml
  def index
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on (whitelist, default to doi)
    # source=source_type

    collection = Article

    @articles = collection.paginate(:page => params[:page], :per_page => params[:per_page])

    respond_to do |format|
      format.html
    end
  end

end
