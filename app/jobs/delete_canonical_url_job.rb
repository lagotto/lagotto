class DeleteCanonicalUrlJob < ActiveJob::Base
  queue_as :high

  def perform(source)
    ActiveRecord::Base.connection_pool.with_connection do
      # reset all canonical urls
      Work.update_all(canonical_url: nil)
    end
  end
end
