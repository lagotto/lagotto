class ErrorMessage < ActiveRecord::Base
  
  scope :total, lambda { |days| where("created_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days).order("created_at DESC") }
  
  def public_message
    case status
    when 404
      message
    else
      "Internal server error"
    end
  end
  
end