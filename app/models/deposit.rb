class Deposit < ActiveRecord::Base
  # include helper module for DOI resolution
  include Resolvable

  # include helper module for extracting identifier
  include Identifiable

  # include helper module for query caching
  include Cacheable

  # include date methods
  include Dateable

  # include deposit processing
  include Processable
  include Processable::WorkProcessor

  belongs_to :work, inverse_of: :deposits, autosave: true
  belongs_to :related_work, class_name: "Work", inverse_of: :deposits, autosave: true
  belongs_to :source, primary_key: :name, inverse_of: :deposits

  before_create :create_uuid
  before_save :set_defaults
  after_commit :queue_deposit_job, :on => :create

  # NB this is coupled to deposits_controller, deposit.rake
  state_machine :initial => :waiting do
    state :waiting, value: 0
    state :working, value: 1
    state :failed, value: 2
    state :done, value: 3

    after_transition :to => [:failed, :done] do |deposit|
      deposit.send_callback if deposit.callback.present?
    end

    after_transition :failed => :waiting do |deposit|
      deposit.queue_deposit_job
    end

    # Reset after failure
    event :reset do
      transition [:failed] => :waiting
      transition any => same
    end

    event :start do
      transition [:waiting] => :working
      transition any => same
    end

    event :finish do
      transition [:working] => :done
      transition any => same
    end

    event :error do
      transition any => :failed
    end
  end

  serialize :subj, JSON
  serialize :obj, JSON
  serialize :error_messages, JSON

  validates :subj_id, :source_id, :source_token, presence: true
  validates_associated :source

  scope :by_state, ->(state) { where("state = ?", state) }
  scope :order_by_date, -> { order("updated_at DESC") }

  scope :waiting, -> { by_state(0).order_by_date }
  scope :working, -> { by_state(1).order_by_date }
  scope :failed, -> { by_state(2).order_by_date }
  scope :stuck, -> { by_state(1).where("updated_at < ?", Time.zone.now - 24.hours).order_by_date }
  scope :done, -> { by_state(3).order_by_date }
  scope :total, ->(duration) { where(updated_at: (Time.zone.now.beginning_of_hour - duration.hours)..Time.zone.now.beginning_of_hour) }

  def self.per_page
    1000
  end

  def to_param  # overridden, use uuid instead of id
    uuid
  end

  def source
    cached_source(source_id)
  end

  def year
    occurred_at.year
  end

  def month
    occurred_at.month
  end

  def send_callback
    data = { "data" => {
               "id" => uuid,
               "type" => "deposits",
               "state" => human_state_name,
               "errors" => error_messages,
               "message_type" => message_type,
               "message_action" => message_action,
               "source_token" => source_token,
               "total" => total,
               "timestamp" => timestamp }}
    Maremma.post(callback, data: data.to_json, token: ENV['API_KEY'])
  end

  def timestamp
    updated_at.utc.iso8601 if updated_at.present?
  end

  def cache_key
    "deposit/#{uuid}-#{timestamp}"
  end

  def create_uuid
    write_attribute(:uuid, SecureRandom.uuid) if uuid.blank?
  end

  def set_defaults
    write_attribute(:subj, {}) if subj.blank?
    write_attribute(:obj, {}) if obj.blank?
    write_attribute(:total, 1) if total.blank?
    write_attribute(:relation_type_id, "references") if relation_type_id.blank?
    write_attribute(:occurred_at, Time.zone.now.utc) if occurred_at.blank?
  end
end
