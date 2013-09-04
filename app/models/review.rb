class Review < ActiveRecord::Base

  belongs_to :filter, :primary_key => "name", :foreign_key => "name", :touch => true

  default_scope where("unresolved = 1").order("reviews.created_at")
  scope :daily_report, where("input > 0 AND created_at = CURDATE()")

  validates :name, :uniqueness => { :scope => :state_id }

  def resolve
    self.update_all(unresolved: false)
  end

  def unresolve
    self.unscoped.update_all(unresolved: true)
  end
end
