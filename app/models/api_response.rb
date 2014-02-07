class ApiResponse < ActiveRecord::Base

  belongs_to :source
  belongs_to :retrieval_status

  attr_accessible :message

  scope :unresolved, where("unresolved = ?", true)
  scope :filter, lambda { |id| where("unresolved = ?", true).where("id <= ?", id).order("api_responses.created_at") }
  scope :total, lambda { |duration| where("created_at > ?", Time.zone.now - duration.days) }
  scope :decreasing, lambda { |source_ids| where("event_count < previous_count").where("retrieval_history_id IS NOT NULL").where(source_id: source_ids) }
  scope :increasing, lambda { |number, source_ids| where("update_interval IS NOT NULL").where("((event_count - previous_count) / update_interval) >= ?", number).where(source_id: source_ids) }
  scope :slow, lambda { |number| where("duration >= ?", number * 1000).where("retrieval_history_id IS NOT NULL") }
  scope :article_not_updated, lambda { |number| where("event_count IS NULL").where("update_interval >= ?", number) }
  scope :source_not_updated, lambda { |number| where("update_interval >= ?", number) }

  # we need integer division, which is handled differently by MySQL and Postgres.
  # Also, Postgres raises error on division by 0 whereas MySQL returns null
  scope :citation_milestone, lambda { |number, source_ids|
    if ActiveRecord::Base.configurations[Rails.env]['adapter'] == "mysql2"
      where("(event_count DIV ?) > (previous_count DIV ?)", number, number).where("source_id IN (?)", source_ids)
    elsif number > 0
      where("(event_count / ?) > (previous_count / ?)", number, number).where("source_id IN (?)", source_ids)
    else
      where("NULL")
    end
  }

end