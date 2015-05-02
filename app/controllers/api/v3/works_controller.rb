class Api::V3::WorksController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :authenticate_user_from_token_param!

  def index
    type = ["doi", "pmid", "pmcid"].find { |t| t == params[:type] } || "doi"
    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| get_clean_id(id) }
    collection = Work.where(works: { type => ids })

    source_ids = get_source_ids(params[:source])
    collection = collection.where(retrieval_statuses: { source_id: source_ids })
                           .includes(:retrieval_statuses).references(:retrieval_statuses)
                           .order("works.updated_at DESC")

    fail ActiveRecord::RecordNotFound, "Article not found." if collection.blank?

    @works = collection.decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source_ids: source_ids })
  end

  def show
    id_hash = get_id_hash(params[:id])
    key, value = id_hash.first
    work = Work.where(key => value)

    source_ids = get_source_ids(params[:source])
    work = work.where(retrieval_statuses: { source_id: source_ids })
               .includes(:retrieval_statuses).references(:retrieval_statuses)
               .first

    fail ActiveRecord::RecordNotFound, "Article not found." if work.blank?

    @work = work.decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source_ids: source_ids })
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: 404
  end

  protected

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
