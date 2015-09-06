namespace :files do
  desc 'upload .env file'
  task :upload do
    on roles(:all) do |host|
      upload! '.env' , "/var/www/#{ENV['APPLICATION']}/shared/.env"
    end
  end
end
