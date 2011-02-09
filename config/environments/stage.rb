# Settings specified here will take precedence over those in config/environment.rb

# The staging environment is meant for nearly finished apps; its
# settings generally mimic production's...
production_env_path = File.join(File.dirname(__FILE__), 'production.rb')
eval(IO.read(production_env_path), binding, production_env_path)

# except:

# Full error reports are enabled and caching is turned off
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

