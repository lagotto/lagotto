class Api::V5::WorkTotalsController < Api::V5::WorksController

  def index
    super
    render "totals"
  end
end
