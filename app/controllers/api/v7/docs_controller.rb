class Api::V7::DocsController < Api::BaseController
  def index
    docs = Doc.all_files
    @docs = DocDecorator.decorate(docs)
  end

  def show
    doc = Doc.find(params[:id])
    render json: { error: "No documentation for #{params[:id]} found" }, status: 404 if doc.id.nil?
    @doc = DocDecorator.decorate(doc)
  end
end
