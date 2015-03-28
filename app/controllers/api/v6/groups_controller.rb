class Api::V6::GroupsController < Api::BaseController
  swagger_controller :groups, "Groups"

  swagger_api :index do
    summary 'Returns all groups, ordered by title'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns group by id'
    param :query, :id, :string, :required, "Group ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    group = Group.where(name: params[:id]).first
    @group = group.decorate
  end

  def index
    collection = Group.order(:title)
    @groups = collection.decorate
  end
end
