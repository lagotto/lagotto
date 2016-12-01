class Api::V5::WorkViewsController < Api::V5::WorksController

  def index
    super
    render "views"
  end
end
