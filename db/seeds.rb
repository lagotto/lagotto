# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# We have created individual seeds files for each model, and have put them into the db/seeds directory

# to load sample articles
# rake db:seed ARTICLES=1

# to update data to a specific version
# rake db:seed VERSION=2.11

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each { |seed| load seed }