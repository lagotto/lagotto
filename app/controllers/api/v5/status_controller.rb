class Api::V5::StatusController < Api::V5::BaseController
  def show
    @status = Status.new
  end
end
