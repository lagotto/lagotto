namespace :deposit do

  desc "Reprocess failed deposits."
  task :reprocess_failed => :environment do
    begin
      from_date = ENV['FROM_DATE'] ? Date.parse(ENV['FROM_DATE']) : (Time.zone.now - 1.day).to_date
      until_date = ENV['UNTIL_DATE'] ? Date.parse(ENV['UNTIL_DATE']) : Time.zone.now.to_date
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all failed deposits from #{from_date} to #{until_date}."

    count = 0
    # NB this is coupled to state machine in deposit.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Deposit.failed.where(updated_at: from_date.beginning_of_day..until_date.end_of_day).pluck_in_batches(:id, 1000) do |ids|
      DepositReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} failed deposits have been queued for reprocessing."
  end

  desc "Reprocess deposits stuck in working state for 24 hours."
  task :reprocess_stuck => :environment do
    begin
      from_date = ENV['FROM_DATE'] ? Date.parse(ENV['FROM_DATE']) : (Time.zone.now - 1.day).to_date
      until_date = ENV['UNTIL_DATE'] ? Date.parse(ENV['UNTIL_DATE']) : Time.zone.now.to_date
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all stuck deposits from #{from_date} to #{until_date}."

    count = 0
    # NB this is coupled to state machine in deposit.rb
    # pluck_in_batches is a custom method in config/initializers/active_record_extensions.rb
    Deposit.stuck.where(updated_at: from_date.beginning_of_day..until_date.end_of_day).pluck_in_batches(:id, 1000) do |ids|
      DepositReprocessJob.perform_later(ids)
      count += ids.length
    end

    puts "#{count} stuck deposits have been queued for reprocessing."
  end
end
