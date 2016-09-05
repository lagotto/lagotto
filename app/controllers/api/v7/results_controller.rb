class Api::V7::ResultsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_work

  def index
    if @work
      collection = @work.results
    elsif params[:work_ids]
      work_ids = params[:work_ids].split(",")
      collection = Result.joins(:work).where(works: { "pid" => work_ids })
    elsif params[:source_id] && source = cached_source(params[:source_id])
      collection = Result.where(source_id: source.id)
    elsif params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      collection = Result.joins(:work).where(works: { "publisher_id" => publisher.id })
    else
      collection = Result
    end

    collection = collection.joins(:source).where("sources.private <= ?", is_admin_or_staff?)

    if params[:sort] == "total"
      collection = collection.order("results.total DESC")
    else
      collection = collection.order("results.updated_at DESC")
    end

    collection = collection.includes(:work, :source, :months)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page, :page => page)

    @results = collection.decorate
  end

  protected

  def load_work
    return nil unless params[:work_id].present?

    id_hash = get_id_hash(params[:work_id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
  end
end
