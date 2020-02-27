class ImportJob < ApplicationJob
  queue_as :high

  def perform(klass, options)
    import = klass.constantize.new(options)
    import.process_data(options)
  end
end
