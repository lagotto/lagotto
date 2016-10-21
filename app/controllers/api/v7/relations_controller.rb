class Api::V7::RelationsController < Api::BaseController
  before_filter :authenticate_user_from_token!, :load_work

  def index
    if @work
      collection = @work.inverse_relations
    else
      collection = Relation

      if params[:work_ids]
        work_ids = params[:work_ids].split(",")
        collection = collection.joins(:work).where(works: { "pid" => work_ids })
      end

      if params[:q]
        collection = collection.joins(:work).where("works.doi = ?", params[:q])
      end
    end

    if params[:relation_type_id] && relation_type = cached_relation_type(params[:relation_type_id])
      collection = collection.where(relation_type_id: relation_type.id)
    end

    if params[:source_id] && source = cached_source(params[:source_id])
      collection = collection.where(source_id: source.id)
    end

    if params[:publisher_id] && publisher = cached_publisher(params[:publisher_id])
      collection = collection.where(publisher_id: publisher.id)
    end

    collection = collection.joins(:related_work)

    if params[:recent]
      collection = collection.last_x_days(params[:recent].to_i)
    end

    if params[:source_id].present? && source = cached_source(params[:source_id])
      @sources = [{ id: params[:source_id],
                    title: source.title,
                    count: collection.where(source_id: source.id).count }]
    else
      sources = collection.where.not(source_id: nil).group(:source_id).count
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

    if params[:relation_type_id].present? && relation_type = cached_relation_type(params[:relation_type_id])
      @relation_types = [{ id: relation_type.name,
                           title: relation_type.title,
                           count: collection.where(relation_type_id: relation_type.id).count }]
    else
      relation_types = collection.where.not(relation_type_id: nil).group(:relation_type_id).count
      relation_type_names = cached_relation_type_names
      @relation_types = relation_types.map { |k,v| { id: relation_type_names[k][:name], title: relation_type_names[k][:title], count: v } }
                                      .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
                                      .first(15)
    end

    collection = collection.order("relations.updated_at DESC")

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    #total_entries = get_total_entries(params, source)

    collection = collection.paginate(per_page: per_page,
                                     page: page)

    @relations = collection.decorate
  end

  # use cached counts for total number of results
  def get_total_entries(params, source)
    case
    when params[:work_id] || params[:work_ids] || params[:q] || params[:relation_type] || params[:recent] then nil # can't be cached
    when source then source.relation_count
    else Relation.count_all
    end
  end

  protected

  def load_work
    return nil unless params[:work_id].present?

    id_hash = get_id_hash(params[:work_id])
    if id_hash.present? && id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
    fail ActiveRecord::RecordNotFound unless @work.present?
  end
end
