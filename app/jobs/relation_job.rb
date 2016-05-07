class RelationJob < ActiveJob::Base
  queue_as :high

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Relation.set_month_id
    end
  end
end
