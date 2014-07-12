class PublishersController < ApplicationController
  before_filter :load_index
  load_and_authorize_resource

  respond_to :html, :js

  def index
    respond_with @publishers
  end

  def create
    @publisher = Publisher.create(safe_params)
    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  def destroy
    @publisher.destroy
    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  protected

  def load_publisher
    @publisher = Publisher.find(params[:id])
  end

  def load_index
    publisher = Publisher.new
    page = params[:page].present? ? params[:page].to_i : 1
    per_page = Publisher.per_page
    offset = (page - 1) * per_page
    result = publisher.query(params[:query], offset, per_page)
    publishers = result[:publishers]
    total_entries = result[:total_entries]

    @publishers = WillPaginate::Collection.create(page, per_page, total_entries) { |pager| pager.replace publishers }
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names, :prefixes)
  end
end
