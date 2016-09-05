class Api::V7::StatusController < Api::BaseController
  before_filter :authenticate_user_from_token!

  def index
    Status.create unless Status.count > 0

    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = Status.all.order("created_at DESC").paginate(:page => page)
    @status = collection.decorate(context: { role: is_admin_or_staff? })
  end
end
