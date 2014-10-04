class PublisherOptionsController < ApplicationController
  before_filter :load_source, only: [:show, :edit, :update]
  # load_and_authorize_resource

  respond_to :js

  def show
    @publisher_option.config = @source.publisher_fields if @publisher_option.config.nil?
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  def edit
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  def update
    @publisher_option.update_attributes(safe_params)
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  protected

  def load_source
    @source = Source.find_by_name(params[:source_id])
    @publisher_option = PublisherOption.find_or_create_by_publisher_id_and_source_id(params[:id], @source.id)

    # raise error if publisher_option wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @publisher_option.blank?
  end

  private

  def safe_params
    params.require(:publisher_option).permit(*@source.publisher_fields)
  end
end
