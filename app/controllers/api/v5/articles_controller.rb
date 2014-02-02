class Api::V5::ArticlesController < Api::V5::BaseController

  def index
    # Filter by source parameter, filter out private sources unless admin
    # Load articles from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    source_ids = get_source_ids(params[:source])

    type = { "doi" => "doi", "pmid" => "pub_med", "pmcid" => "pub_med_central", "mendeley" => "mendeley" }.assoc(params[:type])
    type = type.nil? ? Article.uid : type[1]
    ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }

    if ids
      id_hash = { :articles => { type.to_sym => ids }, :retrieval_statuses => { :source_id => source_ids }}
      collection = ArticleDecorator.where(id_hash)
    else
      collection = ArticleDecorator
      collection = collection.query(params[:q]) if params[:q]
    end

    if params[:class_name]
      @class_name = params[:class_name]
      collection = collection.includes(:alerts)
      if @class_name == "All Alerts"
        collection = collection.where("alerts.unresolved = 1 ")
      else
        collection = collection.where("alerts.unresolved = 1 AND alerts.class_name = ?", @class_name)
      end
    end

    collection = collection.order_articles(params[:order])
    @articles = collection.includes(:retrieval_statuses).paginate(:page => params[:page]).decorate(context: { info: params[:info], source: params[:source] })
  end

  protected

  # Filter by source parameter, filter out private sources unless staff or admin
  def get_source_ids(source_names)
    if source_names and current_user.try(:admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("group_id, sources.display_name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = 0 AND lower(name) in (?)", source_names.split(",")).order("group_id, sources.display_name").pluck(:id)
    elsif current_user.try(:admin_or_staff?)
      source_ids = Source.order("group_id, sources.display_name").pluck(:id)
    else
      source_ids = Source.where("private = 0").order("group_id, sources.display_name").pluck(:id)
    end
  end
end