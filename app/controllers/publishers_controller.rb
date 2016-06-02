class PublishersController < ApplicationController
  before_filter :load_publisher, only: [:show, :destroy]
  before_filter :load_index, only: [:index]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
  end

  def show
    @page = params[:page] || 1
    @source = Source.active.where(name: params[:source_id]).first
    @sort = Source.active.where(name: params[:sort]).first
  end

  def new
    if params[:q]
      collection = Publisher.inactive.query(params[:q])
    else
      collection = Publisher.none
    end
    @publishers = collection.order(:title).paginate(:page => params[:page])

    render :index
  end

  def create
    @publisher = Publisher.where(name: params[:id]).first
    @publisher.update_attributes(active: true) if @publisher.present?

    load_index
    render :index
  end

  def destroy
    @publisher.update_attributes(active: false)
    redirect_to publishers_path
  end

  protected

  def load_publisher
    @publisher = Publisher.active.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless @publisher.present?

    @groups = Group.order("id")
    @page = params[:page] || 1
  end

  def load_index
    collection = Publisher.active
    collection = collection.query(params[:q]) if params[:q]

    if params[:registration_agency_id].present? && registration_agency = cached_registration_agency(params[:registration_agency_id])
      collection = collection.where(registration_agency_id: registration_agency.id)
      @registration_agency_group = collection.where(registration_agency_id: registration_agency.id).group(:registration_agency_id).count.map do |s|
        [cached_registration_agency_id(s[0]), s[1]]
      end.first
    end

    @registration_agencies = collection.where.not(registration_agency_id: nil).group(:registration_agency_id).count.map do |s|
      [cached_registration_agency_id(s[0]), s[1]]
    end

    @publisher_count = collection.count
    @publishers = collection.order(:title).paginate(page: (params[:page] || 1).to_i)
  end

  private

  def safe_params
    params.require(:publisher).permit(:title, :name, :registration_agency, :active, :other_names=> [], :prefixes => [])
  end
end
