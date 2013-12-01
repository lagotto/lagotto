class Api::V3::SourcesController < Api::V3::BaseController

  before_filter :load_source, :only => [:show]
  load_and_authorize_resource

  def index
    articles = Source.for_events.map { |source| source.retrieval_statuses.count(:conditions => "event_count > 0") }
    events = RetrievalStatus.joins(:source).where("state > 0 AND name != 'relativemetric'").order("group_id, display_name").group(:source_id).sum(:event_count).values
    responses = ApiResponse.total(1).group(:source_id).count
    durations = ApiResponse.total(1).group(:source_id).average("duration")
    errors = Alert.total_errors(1).group(:source_id).count

    @sources = Source.active.zip(articles, events).map { |source|
      { name: source.first.name,
        display_name: source.first.display_name,
        state: source.first.human_state_name,
        group: source.first.group_id,
        queueing_count: source.first.get_queueing_job_count,
        pending_count: source.first.delayed_jobs.count - source.first.delayed_jobs.count(:locked_at),
        working_count: source.first.delayed_jobs.count(:locked_at),
        stale_count: source.first.retrieval_statuses.stale.count,
        response_count: responses[source.first.id].nil? ? 0 : responses[source.first.id],
        average_count: durations[source.first.id].nil? ? 0 : durations[source.first.id].to_i,
        error_count: errors[source.first.id].nil? ? 0 : errors[source.first.id],
        article_count: source[1],
        event_count: source[2].nil? ? 0 : source[2],
        update_date: source.first.updated_at.utc.iso8601 }}

    @cache_key = ApiCacheKey.find_by_name("sources")
  end

  def show
    @source = OpenStruct.new({ name: @source.name,
                               display_name: @source.display_name,
                               state: @source.human_state_name,
                               group: @source.group_id,
                               queueing_count: @source.get_queueing_job_count,
                               pending_count: @source.delayed_jobs.count - @source.delayed_jobs.count(:locked_at),
                               working_count: @source.delayed_jobs.count(:locked_at),
                               stale_count: @source.retrieval_statuses.stale.count,
                               response_count: @source.api_responses.total(1).size,
                               error_count: @source.alerts.total_errors(1).size,
                               average_count: @source.api_responses.total(1).average("duration").nil? ? 0 : @source.api_responses.total(1).average("duration").to_i,
                               maximum_count: @source.api_responses.total(1).maximum("duration").nil? ? 0 : @source.api_responses.total(1).maximum("duration").to_i,
                               article_count: @source.articles.cited(1).size,
                               event_count: @source.retrieval_statuses.sum(:event_count),
                               status: [{ "name" => "refreshed", "value" => Article.count - (@source.retrieval_statuses.stale.size + @source.retrieval_statuses.queued.size) },
                                        { "name" => "queued", "value" => @source.retrieval_statuses.queued.size },
                                        { "name" => "stale ", "value" => @source.retrieval_statuses.stale.size }],
                               events: [{ "name" => "with events ",
                                          "day" => @source.retrieval_statuses.with_events(1).size,
                                          "month" => @source.retrieval_statuses.with_events(31).size },
                                        { "name" => "without events",
                                          "day" => @source.retrieval_statuses.without_events(1).size,
                                          "month" => @source.retrieval_statuses.without_events(31).size },
                                        { "name" => "not updated",
                                          "day" => Article.count - (@source.retrieval_statuses.with_events(1).size + @source.retrieval_statuses.without_events(1).size),
                                          "month" => Article.count - (@source.retrieval_statuses.with_events(31).size + @source.retrieval_statuses.without_events(31).size) }],
                               update_date: @source.updated_at.utc.iso8601 })
  end

  protected
  def load_source
    @source = Source.find_by_name(params[:id])
  end
end