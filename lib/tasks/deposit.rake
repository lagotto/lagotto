namespace :deposit do

  desc "Reprocess failed deposits."
  task :reprocess_failed => :environment do
    count = 0
    # NB this is coupled to state machine in deposit.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Deposit.failed.pluck_in_batches(:id, 1000) do |ids|
      DepositReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} failed deposits have been queued for reprocessing."
  end

  desc "Reprocess deposits stuck in working state for 24 hours."
  task :reprocess_stuck => :environment do
    count = 0
    # NB this is coupled to state machine in deposit.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Deposit.stuck.pluck_in_batches(:id, 1000) do |ids|
      DepositReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} stuck deposits have been queued for reprocessing."
  end
end
