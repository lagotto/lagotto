class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    @sources = Source.order("group_id, display_name")
    respond_with @sources
  end
  
end