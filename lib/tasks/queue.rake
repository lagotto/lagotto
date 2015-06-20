namespace :queue do

  desc "Queue stale works (depreciated)"
  task :stale => :environment do |_, args|
    Rake::Task["queue:all"].invoke
    Rake::Task["queue:all"].reenable
  end

  desc "Queue all works"
  task :all => :environment do |_, args|
    if args.extras.empty?
      agents = Agent.active
    else
      agents = Agent.active.where("name in (?)", args.extras)
    end

    if agents.empty?
      puts "No active agent found."
      exit
    end

    begin
      from_pub_date = ENV['FROM_PUB_DATE'] ? Date.parse(ENV['FROM_PUB_DATE']).iso8601 : nil
      until_pub_date = ENV['UNTIL_PUB_DATE'] ? Date.parse(ENV['UNTIL_PUB_DATE']).iso8601 : nil
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all works published from #{from_pub_date} to #{until_pub_date}." if from_pub_date && until_pub_date

    agents.each do |agent|
      count = agent.queue_jobs(from_pub_date: from_pub_date, until_pub_date: until_pub_date)
      puts "#{count} works for agent #{agent.title} have been queued."
    end
  end

  desc "Queue work with given pid"
  task :one, [:pid] => :environment do |_, args|
    if args.pid.nil?
      puts "pid is required"
      exit
    end

    work = Work.where(pid: args.pid).first
    if work.nil?
      puts "Work with pid #{args.pid} does not exist"
      exit
    end

    if args.extras.empty?
      agents = Agent.active
    else
      agents = Agent.active.where("name in (?)", args.extras)
    end

    if agents.empty?
      puts "No active agent found."
      exit
    end

    agents.each do |agent|
      task = Task.where(work_id: work.id, agent_id: agent.id).first

      if task.nil?
        puts "Task for work with pid #{args.pid} and agent with name #{args.agent} does not exist"
        exit
      end

      agent.queue_jobs([task.id], queue: "high")
      puts "Job for pid #{work.pid} and agent #{agent.title} has been queued."
    end
  end

  task :default => :stale

end
