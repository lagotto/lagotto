# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
  unless (REST_AUTH_SITE_KEY rescue nil)
    abort "#{Rails.root}/config/settings.yml doesn't exist or doesn't have a rest_auth_site_key defined.\nSee #{RAILS_ROOT}/config/settings.yml.example."
  end
end

# Don't do any of this if we're Rake-ing.
unless defined?(Rake)
  database_migration_check
  site_keys_check
end
