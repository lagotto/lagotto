class Api::EventsController < Api::BaseController
  prepend_before_filter :load_event, only: [:show, :destroy]
  before_filter :authenticate_user_from_token!, :except => [:index, :show]
  load_and_authorize_resource :except => [:create, :show, :index]
  load_resource :except => [:create, :index]

  def create
    unless safe_params.key? :type
      render json: { errors: [{ status: 422, title: "Missing attribute: type."}] }, status: :unprocessable_entity
    else
      @event = Event.new(safe_params.except(:type))
      authorize! :create, @event

      if @event.save
        render json: @event, :status => :accepted
      else
        errors = @event.errors.full_messages.map { |message| { status: 422, title: message } }
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end

  def show
    render json: @event
  end

  def index
    collection = Event.all
    collection = collection.where(source_token: params[:source_token]) if params[:source_token].present?

    if params[:state]
      # NB this is coupled to event.rb's state machine.
      states = { "waiting" => 0, "working" => 1, "failed" => 2, "done" => 3 }
      state = states.fetch(params[:state], 0)
      collection = collection.where(state: state)
    end

    page = params[:page] || {}
    page[:number] = page[:number] && page[:number].to_i > 0 ? page[:number].to_i : 1
    page[:size] = page[:size] && (1..1000).include?(page[:size].to_i) ? page[:size].to_i : 1000

    total = get_total_entries(params)
    total_pages = (total / page[:size]).ceil

    @events = collection.order("updated_at DESC").page(page[:number]).per_page(page[:size])

    meta = { total: @events.total_entries, 'total-pages' => @events.total_pages, page: page[:number].to_i }
    render json: @events, meta: meta
  end

  def destroy
    if @event.destroy
      render json: { data: {} }, status: :ok
    else
      errors = @event.errors.full_messages.map { |message| { status: 422, title: message } }
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # use cached counts for total number of results
  def get_total_entries(params)
    case
    when params[:source_token] && params[:state] then Event.cached_event_source_token_state_count(params[:source_token], params[:state])
    when params[:source_token] then Event.cached_event_source_token_count(params[:source_token])
    when params[:state] then Event.cached_event_state_count(params[:state])
    when Rails.env.development? || Rails.env.test? then Event.count
    else Event.cached_event_count
    end
  end

  protected

  def load_event
    @event = Event.where(uuid: params[:id]).first

    fail ActiveRecord::RecordNotFound unless @event.present?
  end

  private

  def safe_params
    nested_params = [:pid, :name, { author: [:given, :family, :literal, :orcid] }, :title, :container_title, :issued, :published, :url, :doi, :type]
    attributes = [:uuid, :message_action, :source_token, :callback, :subj_id, :obj_id, :relation_type_id, :source_id, :total, :occurred_at, subj: nested_params, obj: nested_params]
    params.require(:data).permit(:id, :type, attributes: attributes)
  end
end
