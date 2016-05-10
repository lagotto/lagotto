class Api::V7::RegistrationAgenciesController < Api::BaseController
  swagger_controller :registration_agencies, "Registration agencies"

  swagger_api :index do
    summary 'Returns all registration agencies, ordered by title'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns registration agency by id'
    param :path, :id, :string, :required, "Registration agency ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    registration_agency = RegistrationAgency.where(name: params[:id]).first
    @registration_agency = registration_agency.decorate
  end

  def index
    collection = RegistrationAgency.order(:title)
    @registration_agencies = collection.decorate
  end
end
