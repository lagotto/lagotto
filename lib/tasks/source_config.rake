require 'doi'

namespace :db do
  desc "Show configured sources"
  task :source_config => :environment do
    Source.all.each do |s|
      puts "#{s.name}#{" (inactive)" unless s.active}:"
      puts "  URL: '#{s.url}'" if s.uses_url
      puts "  Username: '#{s.username}'" if s.uses_username
      puts "  Password: '#{s.password}'" if s.uses_password
      puts "  Staleness between updates: #{s.staleness_days} days\n"
    end
  end
end
