# encoding: UTF-8

namespace :queue do

  desc "Queue stale works"
  task :stale => :environment do |_, args|
    if args.extras.empty?
      sources = Source.active
    else
      sources = Source.active.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    begin
      start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      end_date = Date.parse(ENV['END_DATE']) if ENV['END_DATE']
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing stale works published from #{start_date} to #{end_date}." if start_date && end_date

    sources.each do |source|
      count = source.queue_all_works(start_date: start_date, end_date: end_date)
      puts "#{count} stale works for source #{source.display_name} have been queued."
    end
  end

  desc "Queue all works"
  task :all => :environment do |_, args|
    if args.extras.empty?
      sources = Source.active
    else
      sources = Source.active.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    begin
      start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      end_date = Date.parse(ENV['END_DATE']) if ENV['END_DATE']
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all works published from #{start_date} to #{end_date}." if start_date && end_date

    sources.each do |source|
      count = source.queue_all_works(all: true, start_date: start_date, end_date: end_date)
      puts "#{count} works for source #{source.display_name} have been queued."
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
      sources = Source.active
    else
      sources = Source.active.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No active source found."
      exit
    end

    sources.each do |source|
      rs = RetrievalStatus.where(work_id: work.id, source_id: source.id).first

      if rs.nil?
        puts "Retrieval Status for work with pid #{args.pid} and source with name #{args.source} does not exist"
        exit
      end

      source.queue_work_jobs([rs.id], priority: 2)
      puts "Job for pid #{work.pid} and source #{source.display_name} has been queued."
    end
  end

  task :default => :stale

end
