class Api::V5::SourcesController < Api::V5::BaseController
  def index
    @sources = SourceDecorator.decorate_collection(Source.visible, context: { nocache: params[:nocache] })
  end

  def show
    @source = Source.where(name: params[:id]).first
    @source = SourceDecorator.decorate(@source)
  end
end
