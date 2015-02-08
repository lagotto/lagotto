namespace :check do
  desc 'Check Lagotto version'
  task :version do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          rake 'check:version'
        end
      end
    end
  end
end
