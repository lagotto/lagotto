class WorksController < ApplicationController
  before_filter :load_work, only: [:show, :edit, :update, :destroy]
  before_filter :new_work, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  respond_to :html, :js

  def index
    @page = params[:page] || 1
    @q = params[:q]
    @class_name = params[:class_name]
    @publisher = Publisher.where(member_id: params[:publisher_id]).first
    @source = Source.visible.where(name: params[:source_id]).first
    @order = Source.visible.where(name: params[:order]).first
  end

  def show
    format_options = params.slice :events, :source

    @groups = Group.order("id")

    respond_with(@work) do |format|
      format.js { render :show }
    end
  end

  def new
    @work = Work.new(day: Time.zone.now.day, month: Time.zone.now.month, year: Time.zone.now.year)
    respond_with(@work) do |format|
      format.js { render :index }
    end
  end

  def create
    @work.save
    respond_with(@work) do |format|
      format.js { render :index }
    end
  end

  def edit
    respond_with(@work) do |format|
      format.js { render :show }
    end
  end

  # PUT /works/:id(.:format)
  def update
    @work.update_attributes(safe_params)
    respond_with(@work) do |format|
      format.js { render :show }
    end
  end

  def destroy
    @work.destroy
    redirect_to works_path
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = get_id_hash(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      fail ActiveRecord::RecordNotFound
    end
  end

  def new_work
    @work = Work.new(safe_params)
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day, :publisher_id, :work_type_id, :scp, :wos, :ark)
  end
end
