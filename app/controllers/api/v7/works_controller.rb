class Api::V7::WorksController < Api::BaseController
  # include helper module for DOI resolution
  include Resolvable

  prepend_before_filter :load_work, only: [:show, :update, :destroy]
  before_filter :authenticate_user_from_token!

  def show
    @work = @work.decorate(context: { role: is_admin_or_staff? })

    fresh_when last_modified: @work.updated_at
  end

  def index
    collection = get_ids(params)

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      collection = collection.joins(:relations)
                             .where("relations.relation_type_id = ?", relation_type.id)
                             .distinct
    end

    if params[:source_id] && source = cached_source(params[:source_id])
      collection = collection.joins(:results)
                             .where("results.source_id = ?", source.id)
                             .where("results.total > 0")
                             .distinct
    end

    if params[:resource_type_id].present?
      collection = collection.where(resource_type_id: params[:resource_type_id])
    end

    if params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      collection = collection.where(publisher_id: publisher.id)
    end

    if params[:member_id].present?
      collection = collection.where(member_id: params[:member_id].upcase)
    end

    if params[:registration_agency_id] && registration_agency = cached_registration_agency(params[:registration_agency_id])
      collection = collection.where(registration_agency_id: registration_agency.id)
    end

    if params[:year].present?
      collection = collection.where(year: params[:year])
    end

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      @relation_types = [{ id: relation_type.name,
                           title: relation_type.title,
                           count: collection.joins(:relations)
                                            .where("relations.relation_type_id = ?", relation_type.id)
                                            .distinct
                                            .count }]
    else
      relation_types = collection.joins(:relations)
                                 .distinct
                                 .group("relations.relation_type_id")
                                 .count
      relation_type_names = cached_relation_type_names
      @relation_types = relation_types.map { |k,v| { id: relation_type_names[k][:name], title: relation_type_names[k][:title], count: v } }
                                      .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
                                      .first(15)
    end

    if params[:source_id] && source = cached_source(params[:source_id])
      @sources = [{ id: source.name,
                    title: source.title,
                    count: collection.joins(:results)
                                     .where("results.source_id = ?", source.id)
                                     .where("results.total > 0")
                                     .distinct
                                     .count }]
    else
      sources = collection.joins(:results)
                          .distinct
                          .group("results.source_id")
                          .count
      source_names = cached_source_names
      @sources = sources.map { |k,v| { id: source_names[k][:name], title: source_names[k][:title], count: v } }
                        .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
                        .first(15)
    end

    if params[:publisher_id].present? && publisher = cached_publisher(params[:publisher_id])
      @publishers = [{ id: publisher.name.underscore.dasherize,
                       title: publisher.title,
                       count: collection.where(publisher_id: publisher.id).count }]
    else
      publishers = collection.where.not(publisher_id: nil).group(:publisher_id).count
      publisher_names = cached_publisher_names
      @publishers = publishers.map { |k,v| { id: publisher_names[k][:name].underscore.dasherize, title: publisher_names[k][:title], count: v } }
                              .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
                              .first(15)
    end

    if params[:resource_type_id].present?
      @resource_types = [{ id: params[:resource_type_id],
                           title: params[:resource_type_id].underscore.humanize,
                           count: collection.where(resource_type_id: params[:resource_type_id]).count }]
    else
      resource_types = collection.where.not(resource_type_id: nil).group(:resource_type_id).count
      @resource_types = resource_types.map { |k,v| { id: k, title: k.underscore.humanize, count: v } }
                                      .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
    end

    if params[:year].present?
      @years = [{ id: params[:year].to_s,
                  title: params[:year].to_s,
                  count: collection.where(year: params[:year]).count }]
    else
      years = collection.where.not(year: nil).group(:year).count
      @years = years.map { |k,v| { id: k.to_s, title: k.to_s, count: v } }
                              .sort { |a, b| b.fetch(:id) <=> a.fetch(:id) }
                              .first(15)
    end

    collection = get_sort(collection, params)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    #total_entries = get_total_entries(params, source, publisher, contributor)

    collection = collection.paginate(per_page: per_page,
                                     page: page)

    @works = collection.decorate(context: { role: is_admin_or_staff? })
  end

  def create
    @work = Work.new(safe_params)
    authorize! :create, @work

    if @work.save
      @status = "created"
      @work = @work.decorate
      render "show", :status => :created
    else
      render json: { meta: { status: "error", error: @work.errors }, work: {}}, status: :bad_request
    end
  end

  def update
    authorize! :update, @work

    if @work.update_attributes(safe_params)
      @work = @work.decorate

      @status = "updated"
      render "show", :status => :ok
    else
      render json: { meta: { status: "error", error: @work.errors }, work: {}}, status: :bad_request
    end
  end

  def destroy
    authorize! :destroy, @work

    if @work.destroy
      render json: { meta: { status: "deleted" }, work: {} }, status: :ok
    else
      render json: { meta: { status: "error", error: "An error occured." }, work: {}}, status: :bad_request
    end
  end

  # Load works from ids listed in query string, use type parameter if present
  # Translate type query parameter into column name
  def get_ids(params)
    if params[:ids]
      type = ["doi", "pmid", "pmcid", "arxiv", "wos", "scp", "ark", "url"].find { |t| t == params[:type] } || "pid"
      type = "canonical_url" if type == "url"
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| get_clean_id(id) }
      collection = Work.where(works: { type => ids })
    elsif params[:q]
      collection = Work.query(params[:q])
    elsif params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      collection = Work.where(publisher_id: publisher.id)
    elsif params[:contributor_id] && contributor = Contributor.where(pid: params[:contributor_id]).first
      collection = Work.joins(:contributions).where("contributions.contributor_id = ?", contributor.id)
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

  # sort by source total
  # we can't filter and sort by two different sources
  def get_sort(collection, params)
    if params[:sort] && sort = cached_source(params[:sort])
      collection.joins(:results)
                .where("results.source_id = ?", sort.id)
                .order("results.total DESC")
    elsif params[:sort] == "created_at"
      collection.order("works.created_at ASC")
    else
      collection.order("works.issued_at DESC")
    end
  end

  # # use cached counts for total number of results
  # def get_total_entries(params, source, publisher, contributor)
  #   # temporarily disable caching
  #   return nil

  #   case
  #   when params[:ids] || params[:q] || params[:class_name] || params[:relation_type_id] || params[:registration_agency] then nil # can't be cached
  #   when source && publisher then publisher.work_count_by_source(source.id)
  #   when source then source.work_count
  #   when publisher then publisher.work_count
  #   #when contributor then contributor.work_count
  #   else Work.count_all
  #   end
  # end

  private

  def safe_params
    params.require(:work).permit(:pid, :doi, :title, :pmid, :pmcid, :canonical_url, :arxiv, :wos, :scp, :ark, :publisher_id, :year, :month, :day, :tracked)
  end
end
