class Api::V5::ArticlesController < Api::V5::BaseController
  def index
    # Filter by source parameter, filter out private sources unless admin
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Paginate query results (50 per page)
    source_ids = get_source_ids(params[:source])
    collection = ArticleDecorator.includes(:retrieval_statuses).where(:retrieval_statuses => { :source_id => source_ids })

    if params[:ids]
      type = ["doi", "pmid", "pmcid", "mendeley_uuid"].find { |t| t == params[:type] } || Article.uid
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }
      collection = collection.where(:articles => { type.to_sym => ids })
    elsif params[:q]
      collection = collection.query(params[:q])
    end

    if params[:class_name]
      @class_name = params[:class_name]
      collection = collection.includes(:alerts)
      if @class_name == "All Alerts"
        collection = collection.where("alerts.unresolved = ?", true)
      else
        collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
      end
    end

    collection = collection.order_articles(params[:order])
    collection = collection.paginate(:page => params[:page])
    @articles = collection.decorate(:context => { :info => params[:info], :source => params[:source] })
  end

  protected

  # Filter by source parameter, filter out private sources unless staff or admin
  def get_source_ids(source_names)
    if source_names && current_user.try(:admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("group_id, sources.display_name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif current_user.try(:admin_or_staff?)
      source_ids = Source.order("group_id, sources.display_name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("group_id, sources.display_name").pluck(:id)
    end
  end
end
