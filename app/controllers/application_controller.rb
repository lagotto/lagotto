class ApplicationController < ActionController::Base
  protect_from_forgery

  APP_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
  layout APP_CONFIG['layout']
end
