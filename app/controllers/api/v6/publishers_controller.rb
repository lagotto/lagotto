class Api::V6::PublishersController < Api::BaseController
  swagger_controller :publishers, "Publishers"

  swagger_api :index do
    summary 'Returns all publishers, sorted by name, 50 per page'
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  swagger_api :show do
    summary 'Returns publisher by member ID'
    param :path, :id, :string, :required, "Member ID"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  def index
    collection = Publisher.order(:name).paginate(:page => params[:page]).all
    @publishers = collection.decorate
  end

  def show
    publisher = Publisher.where(member_id: params[:member_id]).first
    @publisher = publisher.decorate
  end
end
