class ReportWriteLog < ActiveRecord::Base
  scope :order_by_newer_first, -> { order("created_at DESC") }

  validates :filepath, presence: true
end
