class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [ :show, :edit, :update, :destroy ]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    load_index
    respond_with @publishers
  end

  def create
    @publisher = Publisher.create(safe_params)
    load_index
    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  def destroy
    @publisher.destroy
    load_index
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
    publishers = publisher.query(params[:query], offset)

    @publishers = publishers.paginate(:page => page, :per_page => per_page)

    # @publishers = WillPaginate::Collection.create(current_page, per_page, publishers.length) { |pager| pager.replace publishers }
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names, :prefixes)
  end
end
