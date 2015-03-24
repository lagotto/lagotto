class PublisherOptionsController < ApplicationController
  before_filter :load_source, only: [:show, :edit, :update]
  # load_and_authorize_resource

  def show
    @publisher_option.config = @source.publisher_fields if @publisher_option.config.nil?
    render :show
  end

  def edit
    render :show
  end

  def update
    @publisher_option.update_attributes(safe_params)
    render :show
  end

  protected

  def load_source
    @source = Source.where(name: params[:source_name]).first
    @publisher_option = PublisherOption.where(publisher_id: params[:id], source_id: @source.id).first_or_create

    # raise error if publisher_option wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @publisher_option.blank?
  end

  private

  def safe_params
    params.require(:publisher_option).permit(*@source.publisher_fields)
  end
end
