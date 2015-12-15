class ImportJob < ActiveJob::Base
  queue_as :high

  def perform(klass, options)
    ActiveRecord::Base.connection_pool.with_connection do
      import = klass.constantize.new(options)
      import.process_data(options)
    end
  end
end
