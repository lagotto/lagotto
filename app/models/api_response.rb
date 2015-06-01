class ApiResponse < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :agent
  belongs_to :task

  scope :unresolved, -> { where(unresolved: true) }
  scope :work_not_updated, ->(number) { where("skipped = ?", true).where("update_interval >= ?", number) }
  scope :source_not_updated, ->(number) { where("update_interval >= ?", number) }
end
