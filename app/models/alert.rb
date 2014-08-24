class Alert < ActiveRecord::Base
  attr_accessor :exception, :request

  belongs_to :source
  belongs_to :article

  before_create :collect_env_info
  after_create :send_fatal_error_report, if: proc { level == 4 }

  default_scope where("unresolved = ?", true).order("alerts.created_at DESC")

  scope :errors, where("alerts.level > ?", 0)
  scope :query, lambda { |query| includes(:article).where("class_name like ? OR message like ? OR status = ? OR articles.doi = ?", "%#{query}%", "%#{query}%", query, query) }
  scope :total, lambda { |duration| where("created_at > ?", Time.zone.now - duration.days) }
  scope :total_errors, lambda { |duration| where("alerts.level > ?", 0).where("created_at > ?", Time.zone.now - duration.days) }
  scope :from_sources, lambda { |duration| where("source_id IS NOT NULL").where("created_at > ?", Time.zone.now - duration.days) }

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
    report = Report.find_by_name("fatal_error_report")
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
    self.hostname       = hostname || CONFIG[:hostname]

    if exception.kind_of?(String)
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
