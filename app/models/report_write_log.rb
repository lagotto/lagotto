class ReportWriteLog < ActiveRecord::Base
  scope :with_name, -> (name){ where("filepath LIKE '%/#{name}'") }
  scope :order_by_newest_first, -> { order("created_at DESC") }

  def self.most_recent_with_name(name)
    with_name(name).order_by_newest_first.first
  end

  validates :filepath, presence: true
end
