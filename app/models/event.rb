class Event < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source
  has_many :months, :dependent => :destroy

  serialize :extra, JSON

  validates :work_id, :source_id, presence: true
  validates_associated :work, :source

  delegate :name, :to => :source
  delegate :title, :to => :source
  delegate :group, :to => :source

  scope :tracked, -> { joins(:work).where("works.tracked = ?", true) }

  scope :last_x_days, ->(duration) { tracked.where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :not_updated, ->(duration) { tracked.where("retrieved_at < ?", Time.zone.now.to_date - duration.days) }

  scope :published_last_x_days, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_months, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date  - duration.months) }

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }
  scope :with_sources, -> { joins(:source).where("sources.active = ?", 1).order("group_id, title") }

  def to_param
    "#{source.name}:#{work.pid}"
  end

  def group_name
    @group_name ||= group.name
  end

  def title
    @title ||= source.title
  end

  def timestamp
    updated_at.utc.iso8601
  end

  alias_method :display_name, :title
  alias_method :update_date, :timestamp

  # for backwards compatibility in v3 and v5 APIs
  def events
    extra
  end

  def cache_key
    "event/#{id}-#{timestamp}"
  end
end
