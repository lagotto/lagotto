class Admin::EventsController < Admin::ApplicationController
  
  def index
    respond_with do |format|
      format.html
      format.json do
        articles = Source.active.map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
        events = RetrievalStatus.joins(:source).where("sources.active = 1").order("group_id, display_name").group(:source_id).sum(:event_count).values
        @sources = Source.active.zip(articles, events).map { |source| { "name" => source.first.display_name, 
                                                               "url" => admin_source_path(source.first),
                                                               "group" => source.first.group_id, 
                                                               "article_count" => source[1],
                                                               "event_count" => source[2] } }
        render :json => @sources
      end
    end
  end
  
end