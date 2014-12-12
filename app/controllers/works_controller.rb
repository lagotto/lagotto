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
    @publisher = Publisher.where(crossref_id: params[:publisher]).first
    @source = Source.visible.where(name: params[:source]).first
    @order = Source.visible.where(name: params[:order]).first
  end

  def show
    format_options = params.slice :events, :source

    @groups = Group.order("id")

    respond_with(@work) do |format|
      format.js { render :show }
    end
  end

  # GET /works/new
  def new
    @work = Work.new(day: Date.today.day, month: Date.today.month, year: Date.today.year)
    respond_with(@work) do |format|
      format.js { render :index }
    end
  end

  # POST /works
  def create
    @work.save
    respond_with(@work) do |format|
      format.js { render :index }
    end
  end

  # GET /works/:id/edit
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

  # DELETE /works/:id(.:format)
  def destroy
    @work.destroy
    redirect_to works_path
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = Work.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end

    # raise error if work wasn't found
    fail ActiveRecord::RecordNotFound if @work.blank?
  end

  def new_work
    @work = Work.new(safe_params)
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day, :publisher_id)
  end
end
