# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Delete resolved error messages
# Delete API request information, keeping the last 50,000 requests
every :monday, at: "4:00 AM" do
  rake "db:error_messages:delete"
  rake "db:api_requests:delete"  
end

# Learn more: http://github.com/javan/whenever
