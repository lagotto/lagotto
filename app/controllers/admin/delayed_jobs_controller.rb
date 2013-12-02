class Admin::DelayedJobsController < Admin::ApplicationController

  load_and_authorize_resource

  def index
    @sources = Source.active
  end

end
