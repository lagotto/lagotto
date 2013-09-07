class Admin::DelayedJobsController < Admin::ApplicationController

  load_and_authorize_resource

  def index
    @sources = Source.active
    @delayed_jobs = DelayedJob.all
    render :index
  end

end
