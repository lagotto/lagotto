class Api::V4::WorksController < Api::V4::BaseController
  # include works controller methods
  include Workable

  before_filter :load_work, only: [:update, :destroy]

  def create
    @work = Work.new(safe_params)
    authorize! :create, @work

    if @work.save
      @success = "Work created."
      render "show", :status => :created
    else
      render json: { error: @work.errors }, status: :bad_request
    end
  end

  def update
    authorize! :update, @work

    if @work.blank?
      render json: { error: "No work found." }, status: :not_found
    elsif @work.update_attributes(safe_params)
      @success = "Work updated."
      render "show", :status => :ok
    else
      render json: { error: @work.errors }, status: :bad_request
    end
  end

  def destroy
    authorize! :destroy, @work

    if @work.blank?
      render json: { error: "No work found." }, status: :not_found
    elsif @work.destroy
      render json: { success: "Work deleted." }, :status => :ok
    else
      render json: { error: "An error occured." }, status: :bad_request
    end
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
  end
end
