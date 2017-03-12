class Api::WorksController < Api::BaseController
  prepend_before_filter :load_work, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user_from_token!, :except => [:index, :show]
  load_and_authorize_resource :except => [:create, :show, :index]
  load_resource :except => [:create, :index]

  def show
    render json: @work

    fresh_when last_modified: @work.updated_at
  end

  def create
    unless safe_params.key? :type
      render json: { errors: [{ status: 422, title: "Missing attribute: type."}] }, status: :unprocessable_entity
    else
      @work = Work.new(safe_params.except(:type))
      authorize! :create, @work

      if @work.save
        render json: @work, :status => :created, serializer: SimpleWorkSerializer
      else
        errors = @work.errors.full_messages.map { |message| { status: 422, title: message } }
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end

  def update
    unless safe_params.key? :type
      render json: { errors: [{ status: 422, title: "Missing attribute: type."}] }, status: :unprocessable_entity
    else
      if @work.update_attributes(safe_params.except(:type))
        render json: @work, :status => :ok, serializer: SimpleWorkSerializer
      else
        errors = @work.errors.full_messages.map { |message| { status: 422, title: message } }
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @work.destroy
      head :no_content
    else
      render json: { errors: "An error has occurred." }, status: :bad_request
    end
  end

  def index
    if params[:ids]
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| normalize_id(id) }[0...1000]
      collection = Work.where(works: { pid: ids })
    elsif params[:id]
      pid = normalize_id(params[:id])
      if pid.present?
        collection = Work.where(pid: pid)
      else
        collection = Work.none
      end
    else
      collection = Work.indexed
    end

    collection = collection.order("updated_at DESC")

    page = params[:page] || {}
    page[:number] = page[:number] && page[:number].to_i > 0 ? page[:number].to_i : 1
    page[:size] = page[:size] && (1..1000).include?(page[:size].to_i) ? page[:size].to_i : 1000

    total = get_total_entries(params) || collection.count
    total_pages = (total / page[:size]).ceil

    @works = collection.page(page[:number]).per_page(page[:size])

    meta = { total: total, 'total-pages' => total_pages, page: page[:number].to_i }
    render json: @works, meta: meta, each_serializer: SimpleWorkSerializer
  end

  # use cached counts for total number of results
  def get_total_entries(params)
    case
    when params[:ids] || params[:id] then nil # can't be cached
    when Rails.env.development? || Rails.env.test? then Work.indexed.count
    else Work.cached_work_count
    end
  end

  protected

  def load_work
    # Load one work given query params
    pid = normalize_id(params[:id])
    if pid.present?
      @work = Work.where(pid: pid).first
    else
      @work = Work.none
    end
    fail ActiveRecord::RecordNotFound unless @work.present?
  end

  private

  def safe_params
    attributes = [:pid, :provider_id, :indexed]
    params.require(:data).permit(:id, :type, attributes: attributes)
  end
end
