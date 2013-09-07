class Admin::EventsController < Admin::ApplicationController

  skip_authorization_check

  def index
    respond_with do |format|
      format.html do
        authorize! :index, Alert
        @sources = Source.active
      end
      format.json do
        articles = Source.for_events.map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
        events = RetrievalStatus.joins(:source).where("state > 0 AND name != 'relativemetric'").order("group_id, display_name").group(:source_id).sum(:event_count).values
        @sources = Source.for_events.zip(articles, events).map { |source| { "name" => source.first.display_name,
                                                               "url" => admin_source_path(source.first),
                                                               "group" => source.first.group_id,
                                                               "article_count" => source[1],
                                                               "event_count" => source[2] } }
        render :json => @sources
      end
    end
  end

end
