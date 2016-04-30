class Api::V7::PrefixesController < Api::BaseController
  swagger_controller :prefixes, "Prefixes"

  swagger_api :index do
    summary 'Returns all prefixes'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns prefix by prefix'
    param :path, :id, :string, :required, "prefix"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    prefix = Prefix.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless prefix.present?

    @prefix = prefix.decorate
  end

  def index
    collection = Prefix.order(:name)
    @prefixes = collection.decorate
  end
end
