class Api::V5::PublishersController < Api::V5::BaseController
  def index
    @publishers = Publisher.order(:name).paginate(:page => params[:page]).all
  end
end
