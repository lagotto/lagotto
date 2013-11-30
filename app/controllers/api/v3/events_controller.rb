class Api::V3::EventsController < Api::V3::BaseController

  load_and_authorize_resource :alert, :parent => false

  def index
    articles = Source.for_events.map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    events = RetrievalStatus.joins(:source).where("state > 0 AND name != 'relativemetric'").order("group_id, display_name").group(:source_id).sum(:event_count).values
    @sources = Source.for_events.zip(articles, events).map { |source| { name: source.first.display_name,
                                                                        url: admin_source_path(source.first),
                                                                        group: source.first.group_id,
                                                                        article_count: source[1],
                                                                        event_count: source[2] }}
    @cache_key = ApiCacheKey.find_by_name("events")
  end
end