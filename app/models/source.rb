require 'source_helper'
require 'cgi'

class Source < ActiveRecord::Base
  include SourceHelper

  validates_presence_of :name
  validates_presence_of :display_name
  validates_presence_of :url, :if => :uses_url
  validates_presence_of :username, :if => :uses_username
  validates_presence_of :password, :if => :uses_password
  validates_presence_of :api_key, :if => :uses_api_key

  def get_data(article, source_config)
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  # Subclasses should override these to cause fields to appear in UI, and
  # enable their validations
  def uses_url; false; end
  def uses_username; false; end
  def uses_password; false; end
  def uses_api_key; false; end

end
