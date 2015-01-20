namespace :sidekiq do

  desc 'Quiet the sidekiq process'
  task :quiet do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          rake 'sidekiq:quiet'
        end
      end
    end
  end

  desc 'Stop the sidekiq process'
  task :stop do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          rake 'sidekiq:stop'
        end
      end
    end
  end

  desc 'Start the sidekiq process'
  task :start do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          rake 'sidekiq:start'
        end
      end
    end
  end

  desc 'Monitor the sidekiq process'
  task :monitor do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          rake 'sidekiq:monitor'
        end
      end
    end
  end

end
