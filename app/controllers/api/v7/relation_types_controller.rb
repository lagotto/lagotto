class Api::V7::RelationTypesController < Api::BaseController
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
