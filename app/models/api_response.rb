class ApiResponse < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  belongs_to :agent

  scope :unresolved, -> { where(unresolved: true) }
  scope :work_not_updated, ->(number) { where("skipped = ?", true).where("update_interval >= ?", number) }
  scope :source_not_updated, ->(number) { where("update_interval >= ?", number) }
  scope :total, ->(duration) { where(created_at: (Time.zone.now.beginning_of_hour - duration.hours)..Time.zone.now.beginning_of_hour) }
end
