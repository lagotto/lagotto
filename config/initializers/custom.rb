require "csv"

require "#{Rails.root}/lib/source_job.rb"

Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 0
Delayed::Worker.default_priority = 1

APP_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]