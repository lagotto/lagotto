class Api::V3::SourcesController < Api::V3::BaseController

  before_filter :load_source
  load_and_authorize_resource

  def show
    @source = OpenStruct.new({ name: @source.display_name,
                               pending_count: @source.delayed_jobs.count - @source.delayed_jobs.count(:locked_at),
                               working_count: @source.delayed_jobs.count(:locked_at),
                               responses_count: @source.api_responses.total(1).size,
                               alerts_count: @source.alerts.total_errors(1).size,
                               average_count: @source.api_responses.total(1).average("duration").nil? ? nil : @source.api_responses.total(1).average("duration").to_i,
                               maximum_count: @source.api_responses.total(1).maximum("duration").nil? ? nil : @source.api_responses.total(1).maximum("duration").to_i,
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
                                          "month" => Article.count - (@source.retrieval_statuses.with_events(31).size + @source.retrieval_statuses.without_events(31).size) }] })
  end

  protected
  def load_source
    @source = Source.find_by_name(params[:id])
  end
end