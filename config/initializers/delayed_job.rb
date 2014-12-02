sleep_delay = ENV["DJ_SLEEP_DELAY"].to_i

Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = sleep_delay > 0 ? sleep_delay : 5
Delayed::Worker.max_attempts = 10
Delayed::Worker.default_priority = 5
Delayed::Worker.max_run_time = 90.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = !Rails.env.test?
