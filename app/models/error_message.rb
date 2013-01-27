class ErrorMessage < ActiveRecord::Base
  
  attr_accessor :exception, :request
  
  belongs_to :source
  
  before_create :collect_env_info
  
  default_scope where("unresolved = 1").order("created_at DESC")
  
  scope :query, lambda { |query| where("class_name like ? OR message like ? or status = ?", "%#{query}%", "%#{query}%", query) }
  scope :total, lambda { |days| where("created_at > NOW() - INTERVAL ? DAY", days) }
  scope :from_sources, lambda { |days| where("source_id IS NOT NULL AND created_at > NOW() - INTERVAL ? DAY", days) }
  
  def self.per_page
    20
  end
  
  def public_message
    case status
    when 404
      "The requested page was not found"
    else
      "Internal server error"
    end
  end
  
  private
  
  def collect_env_info
    # From https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/public_exceptions.rb and
    # http://www.sharagoz.com/posts/1-rolling-your-own-exception-handler-in-rails-3
    
    return false unless exception
    
    self.class_name     = class_name || exception.class.to_s
    self.message        = message || exception.message
    
    if exception.kind_of?(String)
      self.trace        = nil
    else
      trace             = exception.backtrace.map { |line| line.sub Rails.root.to_s, '' }
      self.trace        = trace.reject! { |line| line =~ /passenger|gems|ruby|synchronize/}.join("\n")
    end
    
    if request
      self.status       = status || request.headers["PATH_INFO"][1..-1]
      self.target_url   = target_url || request.original_url
      self.user_agent   = user_agent || request.user_agent
      self.content_type = content_type || request.formats.first.to_s
    end 
    
    self.source_id      = source_id if source_id
  end
  
end