class Api::V5::PublishersController < Api::BaseController
  swagger_controller :publishers, "Publishers"

  swagger_api :index do
    summary 'Returns all published, sorted by name, 50 per page'
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  def index
    @publishers = Publisher.order(:name).paginate(:page => params[:page]).all
  end
end
