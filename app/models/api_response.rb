class ApiResponse < ActiveRecord::Base

  belongs_to :source

  scope :total, lambda { |days| where("created_at > NOW() - INTERVAL ? DAY", days) }

end
