#!/bin/sh
cd /home/app/webapp
exec 2>&1
exec /sbin/setuser app /usr/bin/env bundle exec sidekiq --config config/sidekiq.yml
