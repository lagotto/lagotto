class Admin::SourcesController < Admin::ApplicationController
  before_filter :load_source, :only => [ :show, :edit, :update ]
  load_and_authorize_resource

  def show
    filename = Rails.root.join("docs/#{@source.name.capitalize}.md")
    @doc = { :text => File.exist?(filename) ? IO.read(filename) : "No documentation found." }
  end

  def index
    filename = Rails.root.join("docs/Sources.md")
    @doc = { :text => File.exist?(filename) ? IO.read(filename) : "No documentation found." }

    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  def update
    @source.update_attributes(source_params)
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  protected
  def load_source
    @source = Source.find_by_name(params[:id])
  end

  private

  def source_params
    params.require(:source).permit(:display_name,
                                   :group,
                                   :state_event,
                                   :private,
                                   :queueable,
                                   :description,
                                   :job_batch_size,
                                   :batch_time_interval,
                                   :rate_limiting,
                                   :wait_time,
                                   :staleness_week,
                                   :staleness_month,
                                   :staleness_year,
                                   :staleness_all,
                                   :timeout,
                                   :max_failed_queries,
                                   :max_failed_query_time_interval,
                                   :disable_delay)
    # @source.get_config_fields
  end
end