#!/bin/sh
if [ "${SERVER_ROLE}" != "secondary" ]; then
  /sbin/setuser app bundle exec whenever --update-crontab -i webapp
fi
