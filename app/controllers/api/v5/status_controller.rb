class Api::V5::StatusController < Api::V5::BaseController
  def index
    @status = StatusDecorator.decorate(Status.new, context: { nocache: params[:nocache] })
  end
end
