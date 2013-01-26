class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    @sources = Source.active
    respond_with @sources
  end
  
end