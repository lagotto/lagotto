# encoding: UTF-8

namespace :workers do

  desc "Start all the workers"
  task :start => :environment do
    status = Worker.start
    puts status[:message] if status[:message]
    if status[:running] < status[:expected]
      puts "Not all workers could be started."
    else
      puts "All #{status[:running]} workers started."
    end
  end

  desc "Stop all the workers"
  task :stop => :environment do
    status = Worker.stop
    puts status[:message] if status[:message]
    if status[:running] > 0
      puts "Not all workers could be stopped."
    else
      puts "All workers stopped."
    end
  end

  desc "Monitor workers"
  task :monitor => :environment do
    status = Worker.monitor
    puts status[:message] if status[:message]
    puts "Missing workers report sent." if status[:expected] > status[:running]
    puts "#{status[:expected]} workers expected, #{status[:running]} workers running."
  end
end
