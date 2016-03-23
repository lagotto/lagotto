class Change < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  belongs_to :source
  belongs_to :aggregation

  scope :unresolved, -> { where(unresolved: true) }
  scope :filter, ->(id) { where(unresolved: true).where("id <= ?", id) }
  scope :total, ->(duration) { where(created_at: (Time.zone.now.beginning_of_hour - duration.hours)..Time.zone.now.beginning_of_hour) }
  scope :decreasing, ->(source_ids) { where("total < previous_total").where(skipped: false).where(source_id: source_ids) }
  scope :increasing, ->(number, source_ids) { where("update_interval IS NOT NULL").where("((total - previous_total) / update_interval) >= ?", number).where(source_id: source_ids) }
  scope :slow, ->(number) { where("duration >= ?", number * 1000).where(skipped: false) }
  scope :ratio, ->(number) { where("if(pdf, html / pdf, 0) >= ?", number).where(skipped: false) }
  scope :work_not_updated, ->(number) { where("skipped = ?", true).where("update_interval >= ?", number) }
  scope :source_not_updated, ->(number) { where("update_interval >= ?", number) }

  # we need integer division, which is handled differently by MySQL and Postgres. Workaround is to use FLOOR.
  scope :citation_milestone, ->(number, source_ids) {
    if number == 0
      limit(0)
    else
      where("FLOOR(total / ?) > FLOOR(previous_total / ?)", number, number).where("source_id IN (?)", source_ids)
    end
  }
end
