class PublishersController < ApplicationController
  before_action :load_publisher, only: [:show, :update, :destroy]
  before_action :new_publisher, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
    load_index
  end

  def show
    @page = params[:page] || 1
    @source = Source.visible.where(name: params[:source_id]).first
    @sort = Source.visible.where(name: params[:sort]).first
  end

  def new
    if params[:query]
      ids = Publisher.pluck(:name)
      publishers = MemberList.new(query: params[:query], per_page: 10).publishers
      @publishers = publishers.reject { |publisher| ids.include?(publisher.name) }
    else
      @publishers = []
    end

    render :index
  end

  def create
    @publisher.save
    load_index
    render :index
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
    @publisher = Publisher.where(name: params[:id]).first
  end

  def load_index
    @publishers = Publisher.order(:title).paginate(:page => params[:page]).all
  end

  private

  def safe_params
    params.require(:publisher).permit(:title, :name, :member_id, :service, :other_names=> [], :prefixes => [])
  end
end
