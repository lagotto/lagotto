set :application, "alm"
set :repository,  "http://svn.ambraproject.org/svn/plos/alm/head"
set :scm, :subversion

set :user, "app"
set :use_sudo, false

# Change these to point to the servers you wish to deploy to.
role :web, "alm.yoursite.org"
role :app, "alm.yoursite.org"
role :db,  "alm.yoursite.org", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_config do
    run "#{try_sudo} mkdir -p #{File.join(shared_path,'config')}"
    %w/ database.yml settings.yml/.each do |f|
      run "#{try_sudo} [ -e #{File.join(shared_path,'config',f)} ] || cp #{File.join(release_path,'config',"#{f}.example")} #{File.join(shared_path,'config',f)}"
    end
    run "#{try_sudo} ln -s #{File.join(shared_path,'config')}/* #{File.join(release_path,'config')}"
  end
end

namespace :bundle do
  desc "Check gem dependencies"
  task :install do
    run "cd #{release_path} && bundle install"
  end
end

after "deploy:update_code", "deploy:symlink_config", "bundle:install"
