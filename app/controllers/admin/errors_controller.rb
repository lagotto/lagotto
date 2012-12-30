class Admin::ErrorsController < Admin::ApplicationController
  
  def index
    @errors = Error.order("updated_at DESC").paginate(:page => params[:page])
    respond_with @errors
  end
  
end