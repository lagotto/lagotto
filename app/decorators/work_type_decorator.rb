class WorkTypeDecorator < Draper::Decorator
  delegate_all

  def id
    to_param
  end
end
