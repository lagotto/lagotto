class SourceDecorator < Draper::Decorator
  delegate_all
  decorates_association :group

  def update_date
    # refresh cache when given nocache parameter
    object.update_column(:cached_at, Time.zone.now) if context[:nocache]

    model.update_date
  end

  def state
    human_state_name
  end

  def group
    object.group.name
  end

  def jobs
    { "working" => working_count,
      "pending" => pending_count }
  end

  def average_count
    model.api_responses.total(1).average("duration")
  end

  def maximum_count
    model.api_responses.total(1).maximum("duration")
  end

  def responses
    { "count" => model.api_responses.total(1).size,
      "average" => average_count.nil? ? 0 : average_count.to_i,
      "maximum" => maximum_count.nil? ? 0 : maximum_count.to_i }
  end

  def error_count
    model.alerts.total_errors(1).size
  end

  def article_count
    model.articles.is_cited.size
  end

  def all_articles_count
    Article.count
  end

  def event_count
    model.retrieval_statuses.sum(:event_count)
  end

  def queued_count
    model.retrieval_statuses.queued.size
  end

  def stale_count
    model.retrieval_statuses.stale.size
  end

  def status
    { "refreshed" => all_articles_count - (stale_count + queued_count),
      "queued" => queued_count,
      "stale" => stale_count }
  end

  def with_events_by_day_count
    model.retrieval_statuses.with_events(1).size
  end

  def without_events_by_day_count
    model.retrieval_statuses.without_events(1).size
  end

  def by_day
    { "with_events" => with_events_by_day_count,
      "without_events" => without_events_by_day_count,
      "not_updated" => all_articles_count - (with_events_by_day_count + without_events_by_day_count) }
  end

  def with_events_by_month_count
    model.retrieval_statuses.with_events(31).size
  end

  def without_events_by_month_count
    model.retrieval_statuses.without_events(31).size
  end

  def by_month
    { "with_events" => with_events_by_month_count,
      "without_events" => without_events_by_month_count,
      "not_updated" => all_articles_count - (with_events_by_month_count + without_events_by_month_count) }
  end
end
