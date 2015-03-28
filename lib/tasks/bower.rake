namespace :bower do
  desc "Install bower packages"
  task :install => :environment do
    sh "node_modules/bower/bin/bower install"
  end

  desc "Update bower packages"
  task :update => :environment do
    sh "node_modules/bower/bin/bower update"
  end

  desc "List bower packages"
  task :list => :environment do
    sh "node_modules/bower/bin/bower list"
  end
end
