class Admin::SourcesController < Admin::ApplicationController
  before_filter :load_source, :only => [ :show, :edit, :update ]
  load_and_authorize_resource

  def show
    @doc = Doc.find(@source.name)
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  def update
    params[:source] ||= {}
    params[:source][:state_event] = params[:state_event] if params[:state_event]
    @source.update_attributes(safe_params)
    if @source.invalid?
      error_messages = @source.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure source #{@source.display_name}: #{error_messages}"
      @flash = flash
    end
    respond_with(@source) do |format|
      if params[:state_event]
        @groups = Group.includes(:sources).order("groups.id, sources.display_name")
        format.js { render :index }
      else
        format.js { render :show }
      end
    end
  end

  protected

  def load_source
    @source = Source.find_by_name(params[:id])
  end

  private

  def safe_params
    params.require(:source).permit(:display_name,
                                   :group_id,
                                   :state_event,
                                   :private,
                                   :queueable,
                                   :description,
                                   :job_batch_size,
                                   :workers,
                                   :batch_time_interval,
                                   :rate_limiting,
                                   :wait_time,
                                   :staleness_week,
                                   :staleness_month,
                                   :staleness_year,
                                   :staleness_all,
                                   :cron_line,
                                   :timeout,
                                   :max_failed_queries,
                                   :max_failed_query_time_interval,
                                   :disable_delay,
                                   :url,
                                   :url_with_type,
                                   :url_with_title,
                                   :related_articles_url,
                                   :api_key,
                                   *@source.config_fields)
  end
end
