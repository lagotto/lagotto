class WorksController < ApplicationController
  before_filter :load_work, only: [:show, :edit, :update, :destroy]
  before_filter :new_work, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
    @page = (params[:page] || 1).to_i
    @q = params[:q]
    @class_name = params[:class_name]
    @publisher = cached_publisher(params[:publisher_id])
    @source = cached_source(params[:source_id])
    @registration_agency = cached_registration_agency(params[:registration_agency_id])
    @sort = Source.active.where(name: params[:sort]).first
    @relation_type = cached_relation_type(params[:relation_type_id])
  end

  def show
    render :show
  end

  def edit
    render :show
  end

  # PUT /works/:id(.:format)
  def update
    @work.update_attributes(safe_params)
    render :show
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
      @work = nil
    end
    fail ActiveRecord::RecordNotFound unless @work.present?

    @groups = Group.order("id")
    @page = params[:page] || 1

    if params[:source_id] && @source = cached_source(params[:source_id])
      @source_group = @work.results.where(source_id: @source.id).group(:source_id).count.map { |s| [cached_source_names[s[0]], s[1]] }.first
    end

    if params[:relation_type_id] && @relation_type = cached_relation_type(params[:relation_type_id])
      @relation_type_group = @work.inverse_relations.where(relation_type_id: @relation_type.id).group(:relation_type_id).count.map { |s| [cached_relation_type_names[s[0]], s[1]] }.first
    end

    if params[:contributor_role_id].present?
      @contributor_role = @work.contributions.where(contributor_role_id: params[:contributor_role_id]).group(:contributor_role_id).count.map { |s| [cached_contributor_role_names[s[0]], s[1]] }.first
    end

    @active = []
    @active += ["relations"] if @work.relations.size > 0
    @active += ["results"] if @work.results.size > 0
    @active += ["contributions"] if @work.contributions.size > 0

    @sources = @work.results.where.not(source_id: nil).group(:source_id).count.map { |s| [cached_source_names[s[0]], s[1]] }
    @relation_types = @work.inverse_relations.where.not(relation_type_id: nil).group(:relation_type_id).count.map { |s| [cached_relation_type_names[s[0]], s[1]] }
    @contributor_roles = @work.contributions.where.not(contributor_role_id: nil).group(:contributor_role_id).count.map { |s| [cached_contributor_role_names[s[0]], s[1]] }
  end

  def new_work
    @work = Work.new(safe_params)
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :canonical_url, :handle_url, :issued_at, :year, :month, :day, :publisher_id, :work_type_id, :arxiv, :scp, :wos, :ark, :dataone, :tracked)
  end
end
