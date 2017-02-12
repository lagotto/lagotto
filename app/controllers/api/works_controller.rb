class Api::WorksController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  prepend_before_filter :load_work, only: [:show, :update, :destroy]
  before_filter :authenticate_user_from_token!

  def show
    render json: @work

    fresh_when last_modified: @work.updated_at
  end

  def index
    collection = get_ids(params)
    collection = collection.order("works.updated_at DESC")

    page = params[:page] || {}
    page[:number] = page[:number] && page[:number].to_i > 0 ? page[:number].to_i : 1
    page[:size] = page[:size] && (1..1000).include?(page[:size].to_i) ? page[:size].to_i : 1000

    total = get_total_entries(params) || collection.count
    total_pages = (total / page[:size]).ceil

    @works = collection.page(page[:number]).per_page(page[:size])

    meta = { total: total, 'total-pages' => total_pages, page: page[:number].to_i }
    render json: @works, meta: meta
  end

  # Load works from ids listed in query string, use type parameter if present
  # Translate type query parameter into column name
  def get_ids(params)
    if params[:ids]
      type = ["doi", "pmid", "pmcid", "arxiv", "wos", "scp", "ark", "url"].find { |t| t == params[:type] } || "pid"
      type = "canonical_url" if type == "url"
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| get_clean_id(id) }
      collection = Work.where(works: { type => ids })
    elsif params[:id]
      id_hash = get_id_hash(params[:id])
      if id_hash.present?
        key, value = id_hash.first
        collection = Work.where(key => value)
      else
        collection = Work.none
      end
    else
      collection = Work.tracked
    end

    collection
  end

  # use cached counts for total number of results
  def get_total_entries(params)
    case
    when params[:ids] || params[:id] then nil # can't be cached
    when Rails.env.development? || Rails.env.test? then Work.tracked.count
    else Work.cached_work_count
    end
  end
end
