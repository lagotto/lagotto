class ErrorMessage < ActiveRecord::Base
  
  scope :total, lambda { |days| where("TIMESTAMPDIFF(DAY, created_at, UTC_TIMESTAMP()) <= ?", days).order("created_at DESC") }
  
end