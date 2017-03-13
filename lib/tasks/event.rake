namespace :deposit do

  desc "Reprocess failed events."
  task :reprocess_failed => :environment do
    count = 0
    # NB this is coupled to state machine in event.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Event.failed.pluck_in_batches(:id, batch_size: 1000) do |ids|
      EventReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} failed events have been queued for reprocessing."
  end

  desc "Reprocess events stuck in working state for 24 hours."
  task :reprocess_stuck => :environment do
    count = 0
    # NB this is coupled to state machine in event.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Event.stuck.pluck_in_batches(:id, batch_size: 1000) do |ids|
      EventReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} stuck events have been queued for reprocessing."
  end
end
