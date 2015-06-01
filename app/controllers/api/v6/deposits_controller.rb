class Api::V6::DepositsController < Api::BaseController
  prepend_before_filter :load_deposit, only: [:show, :destroy]
  before_filter :authenticate_user_from_token!

  def create
    @deposit = Deposit.new(safe_params)
    authorize! :create, @deposit

    if @deposit.save
      @status = "accepted"
      @deposit = @deposit.decorate
      render "show", :status => :accepted
    else
      render json: { meta: { status: "error", error: @deposit.errors }, deposit: {}}, status: :bad_request
    end
  end

  def show
    authorize! :show, @deposit

    @deposit = @deposit.decorate
  end

  def destroy
    authorize! :destroy, @deposit

    if @deposit.destroy
      render json: { meta: { status: "deleted" }, deposit: {} }, status: :ok
    else
      render json: { meta: { status: "error", error: "An error occured." }, deposit: {}}, status: :bad_request
    end
  end

  protected

  def load_deposit
    @deposit = Deposit.where(uuid: params[:id]).first

    fail ActiveRecord::RecordNotFound unless @deposit.present?
  end

  private

  def safe_params
    params.require(:deposit).permit(:uuid, :message_type, :source_token, :callback, message: [works: [], events: []])
  end
end
