class DocsController < ApplicationController
  def index
    @doc = Doc.find("index")
    render :show
  end

  def show
    @doc = Doc.find(params[:id])
    @title = @doc.title
  end
end
