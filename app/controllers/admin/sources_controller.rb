class Admin::SourcesController < Admin::ApplicationController
  before_filter :load_source, :only => [ :show, :edit, :update ]
  load_and_authorize_resource

  def show
    respond_with do |format|
      format.html do
        render :show
      end
      format.json do
        status = [{ "name" => "queued", "value" => @source.retrieval_statuses.queued.size },
                 { "name" => "stale ", "value" => @source.retrieval_statuses.stale.size },
                 { "name" => "refreshed", "value" => Article.count - (@source.retrieval_statuses.stale.size + @source.retrieval_statuses.queued.size) }]
        events = [{ "name" => "with events ",
                           "day" => @source.retrieval_statuses.with_events(1).size,
                           "month" => @source.retrieval_statuses.with_events(31).size },
                         { "name" => "without events",
                           "day" => @source.retrieval_statuses.without_events(1).size,
                           "month" => @source.retrieval_statuses.without_events(31).size },
                         { "name" => "not updated",
                           "day" => Article.count - (@source.retrieval_statuses.with_events(1).size + @source.retrieval_statuses.without_events(1).size),
                           "month" => Article.count - (@source.retrieval_statuses.with_events(31).size + @source.retrieval_statuses.without_events(31).size) }]
        render :json => { "status" => status, "events" => events }
      end
    end
  end

  def index
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end


  def update
    @source.update_attributes(params[:source])
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  protected
  def load_source
    @source = Source.find_by_name(params[:id])
  end
end
