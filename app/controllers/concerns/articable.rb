module Articable
  extend ActiveSupport::Concern

  included do
    def show
      # Load one article given query params
      source_ids = get_source_ids(params[:source])

      id_hash = { :articles => Article.from_uri(params[:id]), :retrieval_statuses => { :source_id => source_ids }}
      @article = ArticleDecorator.includes(:retrieval_statuses).where(id_hash)
        .decorate(context: { info: params[:info], source: source_ids })

      # Return 404 HTTP status code and error message if article wasn't found, or no valid source specified
      if @article.blank?
        if params[:source].blank?
          @error = "Article not found."
        else
          @error = "Source not found."
        end
        render "error", :status => :not_found
      else
        @success = "Article found."
      end
    end

    def index
      # Load articles from ids listed in query string, use type parameter if present
      # Translate type query parameter into column name
      # Paginate query results (50 per page)

      if params[:ids]
        type = ["doi", "pmid", "pmcid", "mendeley_uuid"].find { |t| t == params[:type] } || Article.uid
        ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }
        collection = Article.where(:articles => { type.to_sym => ids })
      elsif params[:q]
        collection = Article.query(params[:q])
      else
        collection = Article
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

      if params[:order] && source = Source.find_by_name(params[:order])
        collection = collection.joins(:retrieval_statuses)
          .where("retrieval_statuses.source_id = ?", source.id)
          .where("retrieval_statuses.event_count > 0")
          .order("retrieval_statuses.event_count DESC")
      else
        collection = collection.order("published_on DESC")
      end

      if params[:publisher]
        collection = collection.where(publisher_id: params[:publisher])
      end

      per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
      source_ids = get_source_ids(params[:source])
      collection = collection.paginate(:per_page => per_page, :page => params[:page], :total_entries => Article.count_all)
      @articles = collection.decorate(:context => { :info => params[:info], :source => source_ids })
    end

    protected

    def load_article
      # Load one article given query params
      id_hash = Article.from_uri(params[:id])
      if id_hash.respond_to?("key")
        key, value = id_hash.first
        @article = Article.where(key => value).decorate.first
      else
        @article = nil
      end
    end

    # Filter by source parameter, filter out private sources unless staff or admin
    def get_source_ids(source_names)
      if source_names && current_user.try(:is_admin_or_staff?)
        Source.where("lower(name) in (?)", source_names.split(",")).order("group_id, sources.display_name").pluck(:id)
      elsif source_names
        Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
      elsif current_user.try(:is_admin_or_staff?)
        Source.order("group_id, sources.display_name").pluck(:id)
      else
        Source.where("private = ?", false).order("group_id, sources.display_name").pluck(:id)
      end
    end

    private

    def safe_params
      params.require(:article).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
    end
  end
end
