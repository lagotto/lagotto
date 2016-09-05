class Api::V7::ContributorRolesController < Api::BaseController
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
