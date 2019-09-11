# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# We have created individual seeds files for each model, and have put them into the db/seeds directory

Dir[File.join(Rails.root, 'db', 'seeds', 'base', '*.rb')].each { |seed| load seed }

# load salted seed data, if any. this won't complain if path doesn't exist.

Dir[File.join('/home/lagotto', 'db', 'seeds', '*.rb')].each { |seed| load seed }

if ENV['SEED_SOURCES']
    load File.join(Rails.root, 'db', 'seeds', 'extra', 'sources.rb')
end