class DocsController < ApplicationController
  def index
    @doc = Doc.find("index")
    @title = @doc.title
    render :show
  end

  def show
    @doc = Doc.find(params[:id])
    @title = @doc.title
  end
end
