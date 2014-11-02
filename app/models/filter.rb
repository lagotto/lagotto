# encoding: UTF-8

class Filter < ActiveRecord::Base
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::TextHelper

  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  has_many :reviews, :primary_key => "name", :foreign_key => "name"

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validate :validate_config_fields

  default_scope { order("name") }
  scope :active, -> { where(:active => true) }

  class << self
    def validates_not_blank(*attrs)
      validates_each attrs do |record, attr, value|
        record.errors.add(attr, "can't be blank") if value.blank?
      end
    end

    def run
      # To sync filters
      # Only run filter if we have unresolved API responses
      options = { id: ApiResponse.unresolved.maximum(:id),
                  input: ApiResponse.unresolved.count(:id),
                  output: 0,
                  started_at: ApiResponse.unresolved.minimum(:created_at),
                  ended_at: ApiResponse.unresolved.maximum(:created_at),
                  review_messages: [] }

      return nil unless options[:id]

      Filter.active.each do |filter|

        options[:name] = filter.name
        options[:display_name] = filter.display_name
        options[:time] = Benchmark.realtime { options[:output] = filter.run_filter(options) }
        options[:message] = formatted_message(options)
        options[:review_messages] << create_review(options)
      end

      resolve(options.except(:name, :display_name))
    end

    def formatted_message(options)
      formatted_input = pluralize(number_with_delimiter(options[:input]), 'API response')
      formatted_output = pluralize(number_with_delimiter(options[:output]), options[:display_name])
      formatted_time = number_with_precision(options[:time] * 1000)

      "Found #{formatted_output} in #{formatted_input}, taking #{formatted_time} ms"
    end

    def create_review(options)
      review = Review.where(name: options[:name], state_id: options[:id]).first_or_initialize
      review.update_attributes(message: options[:message],
                               input: options[:input],
                               output: options[:output],
                               started_at: options[:started_at],
                               ended_at: options[:ended_at])
      options[:message]
    end

    def resolve(options)
      options[:time] = Benchmark.realtime { options[:output] = ApiResponse.filter(options[:id]).update_all(unresolved: false) }
      options[:message] = "Resolved #{pluralize(number_with_delimiter(options[:output]), 'API response')} in #{number_with_precision(options[:time] * 1000)} ms"
      options
    end

    def unresolve(options = {})
      options[:time] = Benchmark.realtime { options[:output] = ApiResponse.update_all(unresolved: true) }
      options[:id] = ApiResponse.maximum(:id)
      options[:message] = "Unresolved #{pluralize(number_with_delimiter(options[:output]), 'API response')} in #{number_with_precision(options[:time] * 1000)} ms"
      options
    end
  end

  # Array of hashes for forms, defined in subclassed filters
  def get_config_fields
    []
  end

  # List of field names for strong_parameters and custom validation
  def config_fields
    get_config_fields.map { |f| f[:field_name].to_sym }
  end

  # Custom validation
  def validate_config_fields
    config_fields.each do |field|
      errors.add(field, "can't be blank") if send(field).blank?
    end
  end

  def limit
    config.limit
  end

  def limit=(value)
    config.limit = value
  end

  def source_ids
    config.source_ids || Source.active.pluck(:id)
  end

  def source_ids=(value)
    config.source_ids = value.map(&:to_i)
  end

  def status
    (active ? "active" : "inactive")
  end

  def run_filter(_options = {})
    fail NotImplementedError, 'Children classes should override run_filter method'
  end

  def raise_alerts(responses)
    responses.each do |response|
      level = response[:level] || 3
      alert = Alert.where(class_name: name,
                          source_id: response[:source_id],
                          article_id: response[:article_id]).first_or_initialize
      alert.update_attributes(exception: "", level: level, message: response[:message] ? response[:message] : "An API response error occured")
    end
  end
end
