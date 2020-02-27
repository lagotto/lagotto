class Review < ApplicationRecord
  belongs_to :filter, :primary_key => "name", :foreign_key => "name", :touch => true

  default_scope { where(:unresolved => true).order("reviews.created_at") }
  scope :daily_report, -> { where("input > ?", 0).where("created_at > ?", Time.zone.now - 1.day) }

  validates :name, :uniqueness => { :scope => :state_id }

  def resolve
    update_all(unresolved: false)
  end

  def unresolve
    unscoped.update_all(unresolved: true)
  end
end
