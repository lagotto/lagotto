class ApiResponse < ActiveRecord::Base

  belongs_to :source
  belongs_to :retrieval_status

  attr_accessible :message

  scope :unresolved, where("unresolved = 1")
  scope :filter, lambda { |id| where("unresolved = 1 AND id <= ?", id).order("api_responses.created_at") }
  scope :total, lambda { |days| where("created_at > NOW() - INTERVAL ? DAY", days) }
  scope :decreasing, where("event_count < previous_count AND retrieval_history_id IS NOT NULL")
  scope :increasing, lambda { |number| where("update_interval IS NOT NULL AND (event_count - previous_count) / IF(update_interval = 0, 1, update_interval) >= ?", number) }
  scope :slow, lambda { |number| where("duration >= ? AND retrieval_history_id IS NOT NULL", number * 1000) }
  scope :article_not_updated, lambda { |number| where("event_count IS NULL AND update_interval >= ?", number) }
  scope :source_not_updated, lambda { |number| where("update_interval >= ?", number) }
  scope :citation_milestone, lambda { |number, source_ids| where("event_count >= ? AND previous_count < ? AND source_id in ?", number, number, source_ids) }

end
