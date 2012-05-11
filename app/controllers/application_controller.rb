require "private_source_filter"

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter PrivateSourceFilter

  layout APP_CONFIG['layout']
end
