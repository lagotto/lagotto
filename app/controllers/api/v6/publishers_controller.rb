class Api::V6::PublishersController < Api::BaseController
  swagger_controller :publishers, "Publishers"

  swagger_api :index do
    summary 'Returns all publishers, sorted by name, 1000 per page'
    param :query, :registration_agency, :string, :optional, "Registration agency"
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  swagger_api :show do
    summary 'Returns publisher by name'
    param :path, :id, :string, :required, "name"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  def index
    collection = Publisher.active
    collection = collection.query(params[:q]) if params[:q]
    collection = collection.where(registration_agency: params[:registration_agency]) if params[:registration_agency]
    collection = collection.order(:title)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page,
                                     page: page)
    @publishers = collection.decorate
  end

  def show
    publisher = Publisher.active.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless publisher.present?

    @publisher = publisher.decorate
  end
end
