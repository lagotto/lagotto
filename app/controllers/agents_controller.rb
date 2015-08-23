class AgentsController < ApplicationController
  before_filter :load_agent, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def show
    @doc = Doc.find(@agent.name)
    if current_user && current_user.publisher_id && @agent.by_publisher?
      @publisher_option = PublisherOption.where(publisher_id: current_user.publisher_id, agent_id: @agent.id).first_or_create
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def index
    @doc = Doc.find("agents")

    @groups = Group.includes(:agents).order("groups.id, agents.title")
  end

  def edit
    @doc = Doc.find(@agent.name)
    if current_user && current_user.publisher_id && @agent.by_publisher?
      @publisher_option = PublisherOption.where(publisher_id: current_user.publisher_id, agent_id: @agent.id).first_or_create
    end
    render :show
  end

  def update
    params[:agent] ||= {}
    params[:agent][:state_event] = params[:state_event] if params[:state_event]
    @agent.update_attributes(safe_params)
    if @agent.invalid?
      error_messages = @agent.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure agent #{@agent.title}: #{error_messages}"
      @flash = flash
    end

    if params[:state_event]
      @groups = Group.includes(:agents).order("groups.id, agents.title")
      render :index
    else
      render :show
    end
  end

  protected

  def load_agent
    @agent = Agent.where(name: params[:id]).first

    # raise error if agent wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @agent.blank?
  end

  private

  def safe_params
    params.require(:agent).permit(:title,
                                  :group_id,
                                  :state_event,
                                  :private,
                                  :by_publisher,
                                  :description,
                                  :queue,
                                  :rate_limiting,
                                  :cron_line,
                                  :timeout,
                                  :max_failed_queries,
                                  :url,
                                  :url_with_type,
                                  :url_with_title,
                                  :related_works_url,
                                  :api_key,
                                  *@agent.config_fields)
  end
end
