class AgentDecorator < Draper::Decorator
  delegate_all
  decorates_association :group

  def state
    human_state_name
  end

  def group
    model.group.name
  end

  def group_id
    model.group.name
  end

  def id
    name
  end

  def source_token
    uuid
  end

  def responses
    { "count" => response_count,
      "average" => average_count,
      "maximum" => maximum_count }
  end

  def status
    { "refreshed" => refreshed_count,
      "queued" => queued_count,
      "stale" => stale_count }
  end
end
