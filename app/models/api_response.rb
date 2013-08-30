class ApiResponse < ActiveRecord::Base

  belongs_to :source
  belongs_to :retrieval_status

  default_scope where("unresolved = 1")

  scope :filter, lambda { |id| where("id <= ?", id).order("api_responses.created_at") }
  scope :total, lambda { |days| where("created_at > NOW() - INTERVAL ? DAY", days) }
  scope :decreasing, where("event_count < previous_count")
  scope :increasing, lambda { |number| where("event_count >= previous_count + ?", number) }
  scope :slow, lambda { |number| where("duration >= ?", number * 1000) }

end
