class Admin::EventsController < Admin::ApplicationController
  
  def index
    gon.articles = Source.order("group_id, display_name").map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    gon.events = RetrievalStatus.joins(:source).order("group_id, display_name").group(:source_id).sum(:event_count).values
    gon.labels = Source.order("group_id, display_name").pluck(:display_name)
    respond_with @sources
  end
  
end