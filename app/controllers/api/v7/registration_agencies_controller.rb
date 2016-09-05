class Api::V7::RegistrationAgenciesController < Api::BaseController
  def show
    registration_agency = RegistrationAgency.where(name: params[:id]).first
    @registration_agency = registration_agency.decorate
  end

  def index
    collection = RegistrationAgency.order(:title)
    @registration_agencies = collection.decorate
  end
end
