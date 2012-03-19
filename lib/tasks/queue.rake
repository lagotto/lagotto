
namespace :queue do

  task :pmc => :environment do

    # this rake task should be scheduled to run after pmc data import rake task runs
    source = Source.find_by_name("pmc")
    source.queue_jobs

  end

  task :counter => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("counter")
    source.queue_jobs

  end

  task :biod => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("biod")
    source.queue_jobs

  end

end

