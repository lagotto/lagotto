class Admin::EventsController < Admin::ApplicationController
  
  def index
    @articles = Source.order("group_id, display_name").map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    @events = RetrievalStatus.joins(:source).order("group_id, display_name").group(:source_id).sum(:event_count).values
    @labels = Source.order("group_id, display_name").pluck(:display_name)
  end
  
end