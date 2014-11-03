namespace :filter do
  desc "Create alerts by filtering API responses"
  task :all => :environment do
    response = Filter.run
    if response.nil?
      puts "Found 0 unresolved API responses"
    else
      response[:review_messages].each { |review_message| puts review_message }
      puts response[:message]
    end
  end

  desc "Unresolve all alerts"
  task :unresolve => :environment do
    response = Filter.unresolve
    puts response[:message]
  end
end
