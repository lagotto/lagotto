class Admin::DelayedJobsController < Admin::ApplicationController
  
  load_and_authorize_resource ErrorMessage 
  
  def index
    if request.xhr?
      @sources = Source.active
      render :partial => "index"
    else
      render :index
    end
  end
  
end