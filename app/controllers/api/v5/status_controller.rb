class Api::V5::StatusController < Api::V5::BaseController
  def index
    @status = Status.new
  end
end
