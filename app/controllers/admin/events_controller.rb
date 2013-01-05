class Admin::EventsController < Admin::ApplicationController
  
  def index
    @sources = Source.includes(:retrieval_statuses).order("name")
    respond_with @sources
  end
  
end