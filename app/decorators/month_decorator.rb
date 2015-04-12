class MonthDecorator < Draper::Decorator
  delegate_all
  decorates_association :source

  def source_id
    model.source.name
  end

  def month
    model.month
  end

  def cache_key
    "months/#{Time.zone.now.to_date}"
  end
end
