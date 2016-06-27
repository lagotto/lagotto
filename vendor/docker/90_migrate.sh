#!/bin/sh
sudo -u app bundle exec rake db:migrate
sudo -u app bundle exec rake db:seed
