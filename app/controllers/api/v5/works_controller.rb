class Api::V5::WorksController < Api::BaseController
  before_filter :authenticate_user_from_token_param!, :load_work, only: [:show]

  def show
    @work = @work.includes(:retrieval_statuses).references(:retrieval_statuses)
      .decorate(context: { info: params[:info], source_id: params[:source_id], role: is_admin_or_staff? })

    fresh_when last_modified: @work.updated_at
  end

  def index
    source = Source.where(name: params[:source_id]).first
    publisher = Publisher.where(member_id: params[:publisher_id]).first
    collection = get_ids(params)
    collection = get_class_name(collection, params) if params[:class_name]
    collection = get_order(collection, params, source)

    if params[:publisher_id] && publisher
      collection = collection.where(publisher_id: params[:publisher_id])
    end

    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
    total_entries = get_total_entries(params, source, publisher)

    collection = collection.paginate(per_page: per_page,
                                     page: params[:page],
                                     total_entries: total_entries)

    fresh_when last_modified: collection.maximum(:updated_at)
    @works = collection.decorate(context: { info: params[:info],
                                            source_id: params[:source_id],
                                            role: is_admin_or_staff? })
  end

  # Load works from ids listed in query string, use type parameter if present
  # Translate type query parameter into column name
  def get_ids(params)
    if params[:ids]
      type = ["doi", "pmid", "pmcid", "arxiv", "wos", "scp", "url"].find { |t| t == params[:type] } || "doi"
      type = "canonical_url" if type == "url"
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| get_clean_id(id) }
      collection = Work.where(works: { type => ids })
    elsif params[:q]
      collection = Work.query(params[:q])
    elsif params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = Work.joins(:retrieval_statuses)
                   .where("retrieval_statuses.source_id = ?", source.id)
                   .where("retrieval_statuses.total > 0")
    else
      collection = Work
    end
  end

  def get_class_name(collection, params)
    @class_name = params[:class_name]
    collection = collection.includes(:alerts).references(:alerts)
    if @class_name == "All Alerts"
      collection = collection.where("alerts.unresolved = ?", true)
    else
      collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
    end
  end

  # sort by source total
  # we can't filter and sort by two different sources
  def get_order(collection, params, source)
    if params[:order] && source && params[:order] == params[:source_id]
      collection = collection.order("retrieval_statuses.total DESC")
    elsif params[:order] && !source && order = Source.where(name: params[:order]).first
      collection = collection.joins(:retrieval_statuses)
        .where("retrieval_statuses.source_id = ?", order.id)
        .order("retrieval_statuses.total DESC")
    else
      collection = collection.order("published_on DESC")
    end
  end

  # use cached counts for total number of results
  def get_total_entries(params, source, publisher)
    case
    when params[:ids] || params[:q] || params[:class_name] then nil # can't be cached
    when source && publisher then publisher.work_count_by_source(source.id)
    when source then source.work_count
    when publisher then publisher.work_count
    else Work.count_all
    end
  end
end
