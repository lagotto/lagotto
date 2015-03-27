class Api::V6::GroupsController < Api::V6::BaseController

  def show
    group = Group.where(name: params[:id]).first
    @group = group.decorate
  end

  def index
    collection = Group.order(:title)
    @groups = collection.decorate
  end
end
