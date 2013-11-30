class Admin::ResponsesController < Admin::ApplicationController

  load_and_authorize_resource :alert, :parent => false

  def index
    @sources = Source.active
  end

end
