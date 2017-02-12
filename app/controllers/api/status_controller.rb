class Api::StatusController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource

  def index
    @status = Status.new
    render json: @status
  end
end
