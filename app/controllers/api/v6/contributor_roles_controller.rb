class Api::V6::ContributorRolesController < Api::BaseController
  swagger_controller :contributor_roles, "Contributor Roles"

  swagger_api :index do
    summary 'Returns all contributor roles, ordered by title'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns contributor role by id'
    param :path, :id, :string, :required, "Contributor role ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    contributor_role = ContributorRole.where(name: params[:id]).first
    if contributor_role.present?
      @contributor_role = contributor_role.decorate
    else
      render json: { meta: { status: "error", error: "Work type #{params[:id]} not found." } }.to_json, status: :not_found
    end
  end

  def index
    collection = ContributorRole.order(:title)
    @contributor_roles = collection.decorate
  end
end
