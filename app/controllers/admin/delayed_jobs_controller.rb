class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    @sources = Source.order("name")
    respond_with @sources
  end
  
  def destroy
    @delayed_job = DelayedJob.find(params[:id])
    @delayed_job.delete
    redirect_to admin_root_path
  end
  
end