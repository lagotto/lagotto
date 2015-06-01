class SourcesController < ApplicationController
  before_filter :load_source, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def show
    @doc = Doc.find(@source.name)
    if current_user && current_user.publisher_id && @source.by_publisher?
      @publisher_option = PublisherOption.where(publisher_id: current_user.publisher_id, source_id: @source.id).first_or_create
    end

    respond_to do |format|
      format.html
      format.js
      format.rss do
        if params[:days]
          @events = @source.events.most_cited
                                .published_last_x_days(params[:days].to_i)
        elsif params[:months]
          @events = @source.events.most_cited
                                .published_last_x_months(params[:months].to_i)
        else
          @events = @source.events.most_cited
        end
        render :show
      end
    end
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.title")
  end

  def edit
    @doc = Doc.find(@source.name)
    if current_user && current_user.publisher_id && @source.by_publisher?
      @publisher_option = PublisherOption.where(publisher_id: current_user.publisher_id, source_id: @source.id).first_or_create
    end
    render :show
  end

  def update
    params[:source] ||= {}
    params[:source][:active] = params[:active] if params[:active]
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
                                   :resolvable,
                                   :by_publisher,
                                   :description)
  end
end
