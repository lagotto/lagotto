class Api::V6::DocsController < Api::BaseController
  def index
    docs = Doc.all_files
    @docs = DocDecorator.decorate(docs)
  end

  def show
    doc = Doc.find(params[:id])
    @doc = DocDecorator.decorate(doc)
  end
end
