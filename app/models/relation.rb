class Relation < ActiveRecord::Base
  belongs_to :work
  belongs_to :related_work, class_name: "Work"
  belongs_to :relation_type
  belongs_to :source
  belongs_to :publisher
  has_many :months, dependent: :destroy

  before_validation :set_occurred_at

  validates :work_id, :presence => true
  validates :related_work_id, :presence => true
  validates :source_id, :presence => true
  validates :relation_type_id, :presence => true

  scope :similar, ->(work_id) { where("total > ?", 0) }
  scope :last_x_days, ->(duration) { where("relations.created_at > ?", Time.zone.now.beginning_of_day - duration.days) }

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{timestamp}"
  end

  def self.count_all
    Status.first && Status.first.relations_count
  end

  def set_occurred_at
    occurred_at = Time.zone.now if occurred_at.blank?
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def by_month
    months.map { |month| month.metrics }
  end

  def by_year
    return [] if by_month.blank?

    by_month.group_by { |event| event[:year] }.sort.map do |k, v|
      { year: k.to_i,
        total: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:total) } }
    end
  end

  def get_events_previous_month
    row = months.last

    if row.nil?
      # first record
      { "total" => 0 }
    elsif [row.year, row.month] == [today.year, today.month]
      # update this month's record
      { "total" => total - row.total }
    else
      # add record
      { "total" => row.total }
    end
  end

  # calculate events for current month based on past numbers
  def get_events_current_month
    row = get_events_previous_month

    { "year" => today.year,
      "month" => today.month,
      "total" => total - row.fetch("total") }
  end

  def update_months(data)
    Array(data).map { |item| Month.where(relation_id: id,
                                         month: item[:month],
                                         year: item[:year]).first_or_create(
                                           work_id: work_id,
                                           source_id: source_id,
                                           total: item.fetch(:total, 0)) }
  end

  def metrics
    @metrics ||= { total: total }
  end
end
