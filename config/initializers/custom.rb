require "csv"

load "#{Rails.root}/lib/source_job.rb"

Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 0


APP_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]