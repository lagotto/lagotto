class Api::V5::SourcesController < Api::V5::BaseController
  before_filter :load_source, :only => [:show]
  load_and_authorize_resource

  def index
    @sources = SourceDecorator.decorate_collection(Source.active)
  end

  def show
    @source = SourceDecorator.new(@source)
  end

  protected

  def load_source
    @source = Source.find_by_name(params[:id])
  end
end
