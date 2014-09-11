class Api::V5::SourcesController < Api::V5::BaseController
  def index
    @sources = SourceDecorator.decorate_collection(Source.active, context: { nocache: params[:nocache] })
  end

  def show
    @source = Source.find_by_name(params[:id])
    @source = SourceDecorator.decorate(@source, context: { nocache: params[:nocache] })
  end
end
