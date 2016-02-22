class Api::V6::RelationTypesController < Api::BaseController
  swagger_controller :relation_types, "Relation Types"

  swagger_api :index do
    summary 'Returns all relation types, ordered by title'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns relation type by id'
    param :path, :id, :string, :required, "Relation type ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def show
    relation_type = cached_relation_type(params[:id])
    if relation_type.present?
      @relation_type = relation_type.decorate
    else
      render json: { meta: { status: "error", error: "Relation type #{params[:id]} not found." } }.to_json, status: :not_found
    end
  end

  def index
    collection = RelationType.order(:title)
    @relation_types = collection.decorate
  end
end
