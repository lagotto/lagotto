class Api::V7::AgentsController < Api::BaseController
  before_filter :authenticate_user_from_token!

  swagger_controller :agents, "Agents"

  swagger_api :index do
    summary 'Returns all agents, sorted by group'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns agent by name'
    param :path, :name, :string, :required, "Agent name"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    collection = Agent.visible.includes(:group)
    @agents = collection.decorate
  end

  def show
    agent = Agent.where(name: params[:id]).first
    @agent = agent.decorate
  end
end
