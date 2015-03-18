class Api::V5::SourcesController < Api::V5::BaseController
  swagger_controller :sources, "Sources"

  swagger_api :index do
    summary 'Returns all sources, sorted by group'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns source by name'
    param :query, :name, :string, :required, "Source name"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @sources = SourceDecorator.decorate_collection(Source.visible)
  end

  def show
    @source = Source.where(name: params[:name]).first
    @source = SourceDecorator.decorate(@source)
  end
end
