namespace :deposit do

  desc "Reprocess failed deposits. Please stop sidekiq during run if this is a large number of deposits."
  task :reprocess_failed => :environment do
    puts "Reprocess failed deposits"

    count = 0
    # NB this is coupled to state machine in deposit.rb
    Deposit.where(state: 2).find_each do |deposit|
      count += 1
      deposit.reprocess
      if count % 1000 == 0
        puts "Processed #{count}..."
      end
    end

    puts "Finished, done #{count}."
  end


end
