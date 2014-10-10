class PublishersController < ApplicationController
  before_filter :load_publisher, only: [:show, :update, :destroy]
  before_filter :new_publisher, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  respond_to :html, :js

  def index
    load_index
    respond_with @publishers
  end

  def show
    if params[:order].present?
      @page = ""
    else
      @page = params[:page] || 1
    end
    @source = Source.visible.where(name: params[:order]).first
  end

  def new
    if params[:query]
      ids = Publisher.pluck(:crossref_id)
      publishers = MemberList.new(query: params[:query], per_page: 10).publishers
      @publishers = publishers.reject { |publisher| ids.include?(publisher.crossref_id) }
    else
      @publishers = []
    end

    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  def create
    @publisher.save
    load_index
    respond_with(@publishers) do |format|
      format.js { render :index }
    end
  end

  def destroy
    @publisher.destroy
    redirect_to publishers_path
  end

  def new_publisher
    params[:publisher] = JSON.parse(params[:publisher], symbolize_names: true)
    @publisher = Publisher.new(safe_params)
  end

  protected

  def load_publisher
    @publisher = Publisher.find_by_crossref_id(params[:id])
  end

  def load_index
    @publishers = Publisher.order(:name).paginate(:page => params[:page]).all
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names=> [], :prefixes => [])
  end
end
