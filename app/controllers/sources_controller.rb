class SourcesController < ApplicationController
  before_filter :load_source, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def show
    @doc = Doc.find(@source.name)
    @sort = @source

    render :show
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.title")
  end

  def edit
    @doc = Doc.find(@source.name)
    render :show
  end

  def update
    params[:source] ||= {}
    params[:source][:active] = params[:active] == "1" if params[:active]
    @source.update_attributes(safe_params)
    if @source.invalid?
      error_messages = @source.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure source #{@source.title}: #{error_messages}"
      @flash = flash
    end

    if params[:active]
      @groups = Group.includes(:sources).order("groups.id, sources.title")
      render :index
    else
      render :show
    end
  end

  protected

  def load_source
    @source = Source.where(name: params[:id]).first

    # raise error if source wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?
  end

  private

  def safe_params
    params.require(:source).permit(:title,
                                   :group_id,
                                   :active,
                                   :private,
                                   :by_publisher,
                                   :queueable,
                                   :description,
                                   :rate_limiting,
                                   :timeout,
                                   :max_failed_queries,
                                   :tracked,
                                   :url,
                                   :url_with_type,
                                   :url_with_title,
                                   :related_works_url,
                                   :api_key)
  end
end
