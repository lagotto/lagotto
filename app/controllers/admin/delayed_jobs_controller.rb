class Admin::DelayedJobsController < Admin::ApplicationController
  
  def destroy
    @delayed_job = DelayedJob.find(params[:id])
    @delayed_job.delete
    flash[:notice] = 'Job was successfully deleted.'
    redirect_to admin_root_path
  end
  
end