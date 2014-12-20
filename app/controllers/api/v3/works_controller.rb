class Api::V3::WorksController < Api::V3::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :load_work, only: [:show]
  before_filter :load_works, only: [:index]

  def index
    source_ids = get_source_ids(params[:source])

    @works = @works.where(retrieval_statuses: { source_id: source_ids })
                   .includes(:retrieval_statuses).references(:retrieval_statuses)
                   .order("works.updated_at DESC")
                   .decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
  end

  def show
    source_ids = get_source_ids(params[:source])

    @work = @work.where(retrieval_statuses: { source_id: source_ids })
                 .includes(:retrieval_statuses).references(:retrieval_statuses)
                 .first
                 .decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = get_id_hash(params[:id])
    key, value = id_hash.first
    @work = Work.where(key => value)

    render json: { error: "Article not found." }.to_json, status: :not_found if @work.empty?
  end

  def load_works
    type = { "doi" => :doi, "pmid" => :pmid, "pmcid" => :pmcid }.values_at(params[:type]).first || :doi
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| get_clean_id(id) }
    @works = Work.where(works: { type => ids })

    render json: { error: "Article not found." }.to_json, status: :not_found if @works.empty?
  end

  # Filter by source parameter, filter out private sources unless admin
  def get_source_ids(source_names)
    if source_names && current_user.try(:is_admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif current_user.try(:is_admin_or_staff?)
      source_ids = Source.order("name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("name").pluck(:id)
    end
  end
end
