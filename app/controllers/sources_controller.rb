class SourcesController < ApplicationController
  before_filter :load_source, :only => [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  respond_to :html, :rss

  def show
    @doc = Doc.find(@source.name)

    respond_with(@source) do |format|
      format.rss do
        if params[:days]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_days(params[:days].to_i)
        elsif params[:months]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_months(params[:months].to_i)
        else
          @retrieval_statuses = @source.retrieval_statuses.most_cited
        end
        render :show
      end
    end
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
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

    # raise error if article wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?
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
                                   :priority,
                                   :workers,
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
