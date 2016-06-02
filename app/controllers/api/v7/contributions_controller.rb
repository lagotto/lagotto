class Api::V7::ContributionsController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :authenticate_user_from_token!, :load_contributor, :load_work

  swagger_controller :contributions, "Contributions"

  swagger_api :index do
    summary "Returns list of works for a particular contributor"
    param :query, :contributor_role_id, :string, :optional, "Contributor_role ID"
    param :query, :source_id, :string, :optional, "Source ID"
    param :query, :publisher_id, :string, :optional, "Publisher ID"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :recent, :integer, :optional, "Limit to contributions created last x days"
    param :query, :per_page, :integer, :optional, "Results per page (0-1000), defaults to 1000"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :internal_server_error
  end

  def index
    if @contributor
      collection = @contributor.contributions
    elsif @work
      collection = @work.contributions
    elsif params[:contributor_id]
      collection = Contribution.none
    else
      collection = Contribution
    end

    if params[:contributor_role_id] && contributor_role = cached_contributor_role(params[:contributor_role_id])
      collection = collection.where(contributor_role_id: contributor_role.id)
    end

    if params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: source.id)
    end

    if params[:publisher_id] && publisher = Publisher.where(name: params[:publisher_id]).first
      collection = collection.where(publisher_id: publisher.id)
    end

    if params[:recent]
      collection = collection.last_x_days(params[:recent].to_i)
    end

    collection = collection.order("contributions.updated_at DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1

    collection = collection.paginate(per_page: per_page,
                                     page: page)

    @contributions = collection.decorate
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
    fail ActiveRecord::RecordNotFound unless @work.present?
  end

  def load_contributor
    return nil unless params[:contributor_id].present?
    pid = get_pid(params[:contributor_id])

    @contributor = Contributor.where(pid: pid).first
  end

  def get_pid(id)
    return nil unless id.present?
    id.starts_with?('http') ? id.gsub(/(http|https):\/+(\w+)/, '\1://\2') : "http://#{id}"
  end
end
