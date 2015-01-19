class Alert < ActiveRecord::Base
  attr_accessor :exception, :request

  belongs_to :source
  belongs_to :work

  before_create :collect_env_info
  after_create :send_fatal_error_report, if: proc { level == 4 }

  default_scope { where("unresolved = ?", true).order("alerts.created_at DESC") }

  scope :errors, -> { where("alerts.level > ?", 1) }
  scope :query, ->(query) { includes(:work).where("class_name like ? OR message like ? OR status = ? OR works.doi = ?", "%#{query}%", "%#{query}%", query, query)
                            .references(:work) }
  scope :total, ->(duration) { where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :total_errors, ->(duration) { where("alerts.level > ?", 1).where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :from_sources, ->(duration) { where("source_id IS NOT NULL").where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }

  # alert level, default is ERROR
  # adapted from http://www.ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html
  LEVELS = %w(DEBUG INFO WARN ERROR FATAL)
  DEBUG  = 0
  INFO   = 1
  WARN   = 2
  ERROR  = 3
  FATAL  = 4

  def self.per_page
    15
  end

  def public_message
    case status
    when 404
      "The page you were looking for doesn't exist."
    else
      "Internal server error."
    end
  end

  def human_level_name
    LEVELS[level]
  end

  def send_fatal_error_report
    report = Report.where(name: 'fatal_error_report').first_or_create(
                          display_name: 'Fatal Error Report',
                          description: 'Reports when a fatal error has occured',
                          interval: 0,
                          private: true)
    report.send_fatal_error_report(message)
  end

  def create_date
    created_at.utc.iso8601
  end

  private

  def collect_env_info
    # From https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/public_exceptions.rb and
    # http://www.sharagoz.com/posts/1-rolling-your-own-exception-handler-in-rails-3

    return false unless exception

    self.class_name     = class_name || exception.class.to_s
    self.message        = message || exception.message
    self.hostname       = hostname || ENV['HOSTNAME']

    if exception.is_a?(String)
      self.trace        = nil
    else
      trace             = exception.backtrace.map { |line| line.sub Rails.root.to_s, '' }
      self.trace        = trace.reject! { |line| line =~ /passenger|gems|ruby|synchronize/ }.join("\n")
    end

    if request
      self.remote_ip    = remote_ip || request.remote_ip
      self.user_agent   = user_agent || request.user_agent
      self.content_type = content_type || request.formats.first.to_s
      self.target_url   = target_url || request.original_url
    end

    self.source_id      = source_id if source_id
  end
end
