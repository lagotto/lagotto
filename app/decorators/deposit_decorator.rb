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

  def occured_at
    object.occured_at.utc.iso8601
  end
end
