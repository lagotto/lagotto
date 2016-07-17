#!/bin/sh
/sbin/setuser app bundle exec rake db:migrate
/sbin/setuser app bundle exec rake db:seed
