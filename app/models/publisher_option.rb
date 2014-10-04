class PublisherOption < ActiveRecord::Base
  # include config methods
  include Configurable

  belongs_to :publisher
  belongs_to :source

  serialize :config, OpenStruct

  # fields with publisher-specific settings such as API keys,
  # i.e. everything that is not a URL
  def publisher_fields
    source.config_fields.select { |field| field !~ /url/ }
  end
end
