class Api::DepositsController < Api::BaseController
  prepend_before_filter :load_deposit, only: [:show, :destroy]
  before_filter :authenticate_user_from_token!, :except => [:index, :show]
  load_and_authorize_resource :except => [:create, :show, :index]
  load_resource :except => [:create, :index]

  def create
    unless safe_params.key? :type
      render json: { errors: [{ status: 422, title: "Missing attribute: type."}] }, status: :unprocessable_entity
    else
      @deposit = Deposit.new(safe_params.except(:type))
      authorize! :create, @deposit

      if @deposit.save
        render json: @deposit, :status => :accepted
      else
        errors = @deposit.errors.full_messages.map { |message| { status: 422, title: message } }
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end

  def show
    render json: @deposit
  end

  def index
    collection = Deposit.all
    collection = collection.where(source_token: params[:source_token]) if params[:source_token].present?

    if params[:state]
      # NB this is coupled to deposit.rb's state machine.
      states = { "waiting" => 0, "working" => 1, "failed" => 2, "done" => 3 }
      state = states.fetch(params[:state], 0)
      collection = collection.where(state: state)
    end

    page = params[:page] || {}
    page[:number] = page[:number] && page[:number].to_i > 0 ? page[:number].to_i : 1
    page[:size] = page[:size] && (1..1000).include?(page[:size].to_i) ? page[:size].to_i : 1000

    total = get_total_entries(params)
    total_pages = (total / page[:size]).ceil

    @deposits = collection.order("updated_at DESC").page(page[:number]).per_page(page[:size])

    meta = { total: @deposits.total_entries, 'total-pages' => @deposits.total_pages, page: page[:number].to_i }
    render json: @deposits, meta: meta
  end

  def destroy
    if @deposit.destroy
      render json: { data: {} }, status: :ok
    else
      errors = @deposit.errors.full_messages.map { |message| { status: 422, title: message } }
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # use cached counts for total number of results
  def get_total_entries(params)
    case
    when params[:source_token] && params[:state] then Deposit.cached_deposit_source_token_state_count(params[:source_token], params[:state])
    when params[:source_token] then Deposit.cached_deposit_source_token_count(params[:source_token])
    when params[:state] then Deposit.cached_deposit_state_count(params[:state])
    when Rails.env.development? || Rails.env.test? then Deposit.count
    else Deposit.cached_deposit_count
    end
  end

  protected

  def load_deposit
    @deposit = Deposit.where(uuid: params[:id]).first

    fail ActiveRecord::RecordNotFound unless @deposit.present?
  end

  private

  def safe_params
    nested_params = [:pid, :name, { author: [:given, :family, :literal, :orcid] }, :title, :container_title, :issued, :published, :url, :doi, :registration_agency_id, :publisher_id, :type, :tracked, :active]
    attributes = [:uuid, :message_type, :message_action, :source_token, :callback, :subj_id, :obj_id, :relation_type_id, :source_id, :publisher_id, :registration_agency_id, :total, :occurred_at, :provenance_url, :timestamp, subj: nested_params, obj: nested_params]
    params.require(:data).permit(:id, :type, attributes: attributes)
  end
end
