class Contribution < ActiveRecord::Base
  # include helper module for query caching
  include Cacheable

  belongs_to :work
  belongs_to :contributor
  belongs_to :contributor_role
  belongs_to :source
  belongs_to :publisher

  validates :work_id, :presence => true
  validates :contributor_id, :presence => true
  validates :source_id, :presence => true

  scope :last_x_days, ->(duration) { where("contributions.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }

  def self.set_month_id
    Contribution.where(month_id: nil).find_each do |contribution|
      result = Result.where(work_id: contribution.work_id,
                            source_id: contribution.source_id).first_or_create

      m = Month.where(work_id: contribution.work_id,
                      source_id: contribution.source_id,
                      year: contribution.occurred_at.year,
                      month: contribution.occurred_at.month,
                      result_id: result.id).first_or_create

      contribution.update_attributes(month_id: m.id)
    end
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end
end
