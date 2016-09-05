class Api::V7::WorkTypesController < Api::BaseController
  def show
    work_type = WorkType.where(name: params[:id]).first
    if work_type.present?
      @work_type = work_type.decorate
    else
      render json: { meta: { status: "error", error: "Work type #{params[:id]} not found." } }.to_json, status: :not_found
    end
  end

  def index
    collection = WorkType.order(:title)
    @work_types = collection.decorate
  end
end
