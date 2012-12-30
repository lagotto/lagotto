class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    @jobs = DelayedJob.select("queue, COUNT(*) as total, COUNT(locked_at) as active, COUNT(failed_at) as failed").group(:queue)
    respond_with @jobs
  end
  
  def destroy
    @delayed_job = DelayedJob.find(params[:id])
    @delayed_job.delete
    redirect_to admin_root_path
  end
  
end