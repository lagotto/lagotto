class InsertEventJob < ActiveJob::Base
  queue_as :critical

  def perform(source, ids = [])
    source.insert_events(ids)
  end
end
