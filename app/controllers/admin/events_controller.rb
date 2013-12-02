class Admin::EventsController < Admin::ApplicationController

  skip_authorization_check

  def index
    authorize! :index, Alert

    @sources = Source.active
  end

end
