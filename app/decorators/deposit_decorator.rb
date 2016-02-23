class DepositDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def state
    human_state_name
  end

  def occurred_at
    object.occurred_at.utc.iso8601
  end

  def errors
    error_messages
  end
end
