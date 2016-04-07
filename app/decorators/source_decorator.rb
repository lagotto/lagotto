class SourceDecorator < Draper::Decorator
  delegate_all
  decorates_association :group

  def group_id
    model.group.name
  end

  def display_name
    title
  end

  def state
    human_state_name
  end

  def id
    name
  end

  def by_day
    { "with_results" => with_results_by_day_count,
      "without_results" => without_results_by_day_count,
      "not_updated" => not_updated_by_day_count }
  end

  def by_month
    { "with_results" => with_results_by_month_count,
      "without_results" => without_results_by_month_count,
      "not_updated" => not_updated_by_month_count }
  end
end
