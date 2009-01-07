# Lifted from Advanced Rails Recipes #38: Fail Early --
# check to make sure we've got the right database version, and
# make sure we've got a site_keys initializer

def database_migration_check
  current_version = ActiveRecord::Migrator.current_version rescue 0
  highest_version = Dir.glob("#{RAILS_ROOT}/db/migrate/*.rb" ).map { |f|
    f.match(/(\d+)_.*\.rb$/) ? $1.to_i : 0
  }.max

  # skip when run from tasks like rake db:migrate, or our Capistrano rules
  unless ENV['NO_MIGRATION_CHECK'] 
    if current_version != highest_version
      abort "#{RAILS_ENV.capitalize} database isn't the current migration version: expected #{highest_version}, got #{current_version}"
    else
      # puts "#{RAILS_ENV.capitalize} database migration version is the expected one: #{current_version}"
    end
  else
    #puts "Skipping database migration check"
  end
end

def site_keys_check
  unless File.exist?("#{RAILS_ROOT}/config/initializers/site_keys.rb")
    abort "#{RAILS_ROOT}/config/initializers/site_keys.rb doesn't exist - see #{RAILS_ROOT}/config/initializers/site_keys_example"
  end
end

# Don't do any of this if we're Rake-ing.
unless defined?(Rake)
  database_migration_check
  site_keys_check
end
