class PublisherOption < ActiveRecord::Base
  # include config methods
  include Configurable

  belongs_to :publisher
  belongs_to :agent

  serialize :config, OpenStruct

  validate :validate_publisher_fields, :on => :update

  # fields with publisher-specific settings such as API keys,
  # i.e. everything that is not a URL
  def publisher_fields
    agent.config_fields.select { |field| field !~ /url/ }
  end

  # Custom validations
  def validate_publisher_fields
    publisher_fields.each do |field|

      # Some fields can be blank
      next if agent.name == "crossref" && field == :password
      next if agent.name == "mendeley" && field == :access_token
      next if agent.name == "twitter_search" && field == :access_token
      next if agent.name == "scopus" && field == :insttoken

      errors.add(field, "can't be blank") if send(field).blank?
    end
  end
end
