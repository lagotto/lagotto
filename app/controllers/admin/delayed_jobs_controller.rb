class Admin::DelayedJobsController < Admin::ApplicationController
  
  def index
    if request.xhr?
      @sources = Source.active
      render :partial => "index"
    else
      render :index
    end
  end
  
end