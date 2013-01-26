class Admin::EventsController < Admin::ApplicationController
  
  def index
    sources = Source.active
    articles = Source.active.map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    events = RetrievalStatus.joins(:source).order("group_id, display_name").group(:source_id).sum(:event_count).values
    @data = sources.zip(articles, events).map { |source| { "name" => source.first.display_name, 
                                                           "url" => admin_source_path(source.first.id),
                                                           "group" => source.first.group_id, 
                                                           "article_count" => source[1],
                                                           "event_count" => source[2] } }.to_json
    @article_count = Article.count
  end
  
end