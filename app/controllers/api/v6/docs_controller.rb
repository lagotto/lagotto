class Api::V6::DocsController < Api::BaseController
  swagger_controller :docs, "Docs"

  swagger_api :index do
    summary 'Returns all documents'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns document by id'
    param :path, :id, :string, :required, "Document ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

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
