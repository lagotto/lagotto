class Api::V6::WorkTypesController < Api::BaseController
  swagger_controller :work_types, "Work Types"

  swagger_api :index do
    summary 'Returns all work types, ordered by title'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns work type by id'
    param :path, :id, :string, :required, "Work type ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    work_type = WorkType.where(name: params[:name]).first
    if work_type.present?
      @work_type = work_type.decorate
    else
      render json: { meta: { status: "error", error: "Work type #{params[:name]} not found." } }.to_json, status: :not_found
    end
  end

  def index
    collection = WorkType.order(:title)
    @work_types = collection.decorate
  end
end
