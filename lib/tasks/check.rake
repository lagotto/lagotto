namespace :check do
  desc "Check Lagotto version"
  task :version => :environment do
    puts Lagotto::VERSION
  end
end
