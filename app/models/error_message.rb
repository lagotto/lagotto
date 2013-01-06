class ErrorMessage < ActiveRecord::Base
  
  scope :total, lambda { |days| where("created_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days).order("created_at DESC") }
  
  def public_message
    case status_code
    when 404
      "Page not found"
    when 500
      "Internal server error"
    else
      "An error occured"
    end
  end
  
end