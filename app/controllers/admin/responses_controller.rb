class Admin::ResponsesController < Admin::ApplicationController
  
  def index
    @sources = Source.order("name")
    respond_with @sources
  end

end