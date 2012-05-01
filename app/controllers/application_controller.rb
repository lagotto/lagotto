require "private_source_filter"

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter PrivateSourceFilter

  APP_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
  layout APP_CONFIG['layout']
end
