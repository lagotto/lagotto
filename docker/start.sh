#!/bin/sh

# Set up the database and then start puma. Used as CMD in salt docker container

docker/wait-for.sh -t 30 $1
bundle exec rake db:create db:migrate
bundle exec puma -C config/puma.rb
