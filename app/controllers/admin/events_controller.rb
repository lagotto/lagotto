class Admin::EventsController < Admin::ApplicationController
  
  def index
    @sources = Source.order("name")
    gon.articles = Source.order("name").map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    gon.events = RetrievalStatus.group(:source_id).sum(:event_count).values
    gon.labels = Source.order("id").pluck(:display_name)
    respond_with @sources
  end
  
end