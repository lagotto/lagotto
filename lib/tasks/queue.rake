namespace :queue do
  # observe next update derived from cron_line. Otherwise the same as queue:all
  desc "Queue stale works"
  task :stale => :environment do |_, args|
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
      from_date = ENV['FROM_DATE'] ? Date.parse(ENV['FROM_DATE']).iso8601 : (Time.zone.now.to_date - 1.day).iso8601
      until_date = ENV['UNTIL_DATE'] ? Date.parse(ENV['UNTIL_DATE']).iso8601 : Time.zone.now.to_date.iso8601
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all works published from #{from_date} to #{until_date}."

    agents.each do |agent|
      count = agent.queue_jobs(from_date: from_date, until_date: until_date)
      puts "#{count} works for agent #{agent.title} have been queued."
    end
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
      from_date = ENV['FROM_DATE'] ? Date.parse(ENV['FROM_DATE']).iso8601 : (Time.zone.now.to_date - 1.day).iso8601
      until_date = ENV['UNTIL_DATE'] ? Date.parse(ENV['UNTIL_DATE']).iso8601 : Time.zone.now.to_date.iso8601
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all works published from #{from_date} to #{until_date}."

    agents.each do |agent|
      count = agent.queue_jobs(all: true, from_date: from_date, until_date: until_date)
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
      agent.queue_jobs([work.id], queue: "high")
      puts "Job for pid #{work.pid} and agent #{agent.title} has been queued."
    end
  end

  task :default => :stale

end
