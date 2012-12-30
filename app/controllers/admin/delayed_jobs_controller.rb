class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    @sources = Source.joins("LEFT OUTER JOIN delayed_jobs ON sources.name = delayed_jobs.queue").select("sources.id as id, sources.display_name as display_name, COUNT(run_at) as total, COUNT(locked_at) as locked, COUNT(failed_at) as failed").group(:queue)
    respond_with @sources
  end
  
end