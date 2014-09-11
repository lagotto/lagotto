class StatusDecorator < Draper::Decorator
  delegate_all

  def update_date
    # refresh cache when given nocache parameter
    Rails.cache.write('status:timestamp', Time.zone.now.utc.iso8601) if context[:nocache]

    model.update_date
  end
end
