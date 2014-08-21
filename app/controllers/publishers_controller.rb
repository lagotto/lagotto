class PublishersController < ApplicationController
  before_filter :load_index, :only => [ :index, :create ]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    respond_with @publishers
  end

  def new
    @publishers = MemberList.new(query: params[:query], per_page: 10).publishers

    respond_with(@publishers) do |format|
      format.js { render :index }
    end
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
    @publishers = Publisher.order(:name).paginate(:page => params[:page])
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names, :prefixes)
  end
end
