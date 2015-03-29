namespace :bower do
  desc "Install bower packages"
  task :install => :environment do
    Dir.chdir("frontend") { sh "node_modules/.bin/bower install" }
  end

  desc "Update bower packages"
  task :update => :environment do
    ir.chdir("frontend") { sh "node_modules/.bin/bower update" }
  end

  desc "List bower packages"
  task :list => :environment do
    ir.chdir("frontend") { sh "node_modules/.bin/bower list" }
  end
end
