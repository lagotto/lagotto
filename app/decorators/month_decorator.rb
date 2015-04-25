class MonthDecorator < Draper::Decorator
  delegate_all
  decorates_association :source

  def source_id
    model.source.name
  end

  def month
    model.month
  end
end
