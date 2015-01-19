class Api::V5::StatusController < Api::V5::BaseController
  def index
    Status.create unless Status.count > 0

    collection = Status.all
    @status = collection.order("created_at DESC").paginate(:page => params[:page])

    @user = current_user ? current_user.cache_key : "2"
  end
end
