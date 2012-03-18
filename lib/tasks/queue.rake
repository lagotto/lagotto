
namespace :queue do

  task :pmc => :environment do

    # this rake task should be scheduled to run after pmc data import rake task runs
    source = Source.find_by_name("pmc")
    source.queue_jobs

  end

end

