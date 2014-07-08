class Api::V5::SourcesController < Api::V5::BaseController
  def index
    @sources = SourceDecorator.decorate_collection(Source.active)
  end

  def show
    @source = Source.find_by_name(params[:id])
    @source = SourceDecorator.new(@source)
  end
end
