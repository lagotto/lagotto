class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [:show, :update, :destroy]
  before_filter :load_index, :only => [:index, :create]
  before_filter :new_publisher, :only => [:create]
  load_and_authorize_resource

  respond_to :html, :js

  def index
    respond_with @publishers
  end

  def new
    ids = Publisher.pluck(:crossref_id)
    publishers = MemberList.new(query: params[:query], per_page: 10).publishers
    @publishers = publishers.reject { |publisher| ids.include?(publisher.crossref_id) }

    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  def create
    @publisher.save
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

  def new_publisher
    @publisher = Publisher.new(safe_params)
  end

  protected

  def load_publisher
    @publisher = Publisher.find_by_crossref_id(params[:id])
  end

  def load_index
    @publishers = Publisher.order(:name).paginate(:page => params[:page])
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names=> [], :prefixes => [])
  end
end
