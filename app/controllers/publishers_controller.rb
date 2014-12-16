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
    @page = params[:page] || 1
    @source = Source.visible.where(name: params[:source_id]).first
    @order = Source.visible.where(name: params[:order]).first
  end

  def new
    if params[:query]
      ids = Publisher.pluck(:member_id)
      publishers = MemberList.new(query: params[:query], per_page: 10).publishers
      @publishers = publishers.reject { |publisher| ids.include?(publisher.member_id) }
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
    @publisher = Publisher.where(member_id: params[:id]).first
  end

  def load_index
    @publishers = Publisher.order(:title).paginate(:page => params[:page]).all
  end

  private

  def safe_params
    params.require(:publisher).permit(:title, :name, :member_id, :service, :other_names=> [], :prefixes => [])
  end
end
