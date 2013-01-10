class Admin::EventsController < Admin::ApplicationController
  
  def index
    @sources = Source.order("name")
    @events_count = RetrievalStatus.group(:source_id).sum(:event_count)
    respond_with @sources
  end
  
end