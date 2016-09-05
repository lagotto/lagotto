class Api::V7::AgentsController < Api::BaseController
  before_filter :authenticate_user_from_token!

  def index
    collection = Agent.visible.includes(:group)
    @agents = collection.decorate
  end

  def show
    agent = Agent.where(name: params[:id]).first
    @agent = agent.decorate
  end
end
