class Api::V7::ContributionsController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  before_filter :authenticate_user_from_token!, :load_contributor, :load_work

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

    if params[:source_id] && source = cached_source(params[:source_id])
      collection = collection.where(source_id: source.id)
    end

    if params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      collection = collection.where(publisher_id: publisher.id)
    end

    if params[:recent]
      collection = collection.last_x_days(params[:recent].to_i)
    end

    if params[:source_id] && source = cached_source(params[:source_id])
      @sources = { params[:source_id] => collection.where(source_id: source.id).count }
    else
      sources = collection.where.not(source_id: nil).group(:source_id).count
      source_names = cached_source_names
      @sources = sources.map { |k,v| [source_names[k], v] }.to_h
    end

    if params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      @publishers = { params[:publisher_id] => collection.where(publisher_id: publisher.id).count }
    else
      publishers = collection.where.not(publisher_id: nil).group(:publisher_id).count
      publisher_names = cached_publisher_names
      @publishers = publishers.map { |k,v| [publisher_names[k], v] }.to_h
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
