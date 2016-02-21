class Deposit < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  before_create :create_uuid
  before_save :set_defaults
  after_commit :queue_deposit_job, :on => :create

  state_machine :initial => :waiting do
    state :waiting, value: 0
    state :working, value: 1
    state :failed, value: 2
    state :done, value: 3

    after_transition :to => [:failed, :done] do |deposit|
      deposit.send_callback if deposit.callback.present?
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

  validates :source_token, presence: true
  validates :subj_id, presence: true
  validates :source_id, presence: true

  scope :by_state, ->(state) { where("state = ?", state) }
  scope :order_by_date, -> { order("updated_at DESC") }

  scope :waiting, -> { by_state(0).order_by_date }
  scope :working, -> { by_state(1).order_by_date }
  scope :failed, -> { by_state(2).order_by_date }
  scope :done, -> { by_state(3).order_by_date }
  scope :total, ->(duration) { where(updated_at: (Time.zone.now.beginning_of_hour - duration.hours)..Time.zone.now.beginning_of_hour) }

  def self.per_page
    1000
  end

  def queue_deposit_job
    DepositJob.perform_later(self)
  end

  def to_param  # overridden, use uuid instead of id
    uuid
  end

  def process_message
    case
    when message_type == "publisher" && message_action == "delete" then delete_publisher
    when message_type == "publisher" then update_publisher
    when message_type == "contributor" && message_action == "delete" then delete_contributor
    when message_type == "contributor" then update_contributor
    when message_type == "work" && message_action == "delete" then delete_work
    else update_work
    end
  end

  def update_work
    doi = subj.fetch("DOI", nil)
    pmid = subj.fetch("PMID", nil)
    pmcid = subj.fetch("PMCID", nil)
    arxiv = subj.fetch("arxiv", nil)
    ark = subj.fetch("ark", nil)
    canonical_url = subj.fetch("URL", nil)

    title = subj.fetch("title", nil)
    date_parts = subj.fetch("issued", {}).fetch("date-parts", [[]]).first
    year, month, day = date_parts[0], date_parts[1], date_parts[2]
    type = subj.fetch("type", nil)
    work_type_id = WorkType.where(name: type).pluck(:id).first
    registration_agency = subj.fetch("registration_agency", nil)
    tracked = subj.fetch("tracked", false)

    csl = {
      "author" => subj.fetch("author", []),
      "container-title" => subj.fetch("container-title", nil),
      "volume" => subj.fetch("volume", nil),
      "page" => subj.fetch("page", nil),
      "issue" => subj.fetch("issue", nil) }

    work = Work.where(pid: subj_id).first_or_create(
      doi: doi,
      pmid: pmid,
      pmcid: pmcid,
      arxiv: arxiv,
      ark: ark,
      canonical_url: canonical_url,
      title: title,
      year: year,
      month: month,
      day: day,
      work_type_id: work_type_id,
      tracked: tracked,
      registration_agency: registration_agency,
      csl: csl)

    work ? work.pid : nil
  end

  # def update_events
  #   Array(message.fetch('events', nil)).map do |item|
  #     source_id = item.fetch("source_id", nil)
  #     source = Source.where(name: source_id).first
  #     raise ArgumentError.new("Source #{source_id.to_s} not found for deposit id #{uuid}") unless source.present?

  #     pid = item.fetch("work_id", nil)
  #     work = Work.where(pid: pid).first
  #     raise ArgumentError.new("Work #{pid.to_s} not found for deposit id #{uuid}") unless source.present?

  #     total = item.fetch("total", 0)

  #     # only create event row if we have at least one event
  #     if total > 0
  #       begin
  #         event = Event.where(source_id: source.id, work_id: work.id).first_or_create
  #       rescue ActiveRecord::RecordNotUnique
  #         event = Event.where(source_id: source.id, work_id: work.id).first
  #       end
  #     else
  #       event = Event.where(source_id: source.id, work_id: work.id).first
  #     end

  #     next unless event.present?

  #     event.update_attributes(retrieved_at: Time.zone.now,
  #                             total: total,
  #                             pdf: item.fetch("pdf", 0),
  #                             html: item.fetch("html", 0),
  #                             readers: item.fetch("readers", 0),
  #                             comments: item.fetch("comments", 0),
  #                             likes: item.fetch("likes", 0),
  #                             events_url: item.fetch("events_url", nil),
  #                             extra: item.fetch("extra", nil))

  #     months = item.fetch("months", [])
  #     months = [event.get_events_current_month] if months.blank?
  #     update_months(event, months)

  #     event
  #   end
  # end

  def update_publisher
    publisher = Publisher.where(name: subj_id).first_or_create
    publisher.update_attributes(subj.except('name'))
  end

  # def delete_events
  #   Array(message.fetch('events', nil)).map do |item|
  #     Event.where(source_id: item.fetch('source_id', nil), work_id: item.fetch("work_id", nil)).destroy_all
  #   end
  # end

  def delete_work
    Work.where(pid: subj_id).destroy_all
  end

  def delete_publisher
    Publisher.where(name: subj_id).destroy_all
  end

  def update_months(event, months)
    months.map { |item| Month.where(event_id: event.id,
                                    month: item.fetch("month"),
                                    year: item.fetch("year")).first_or_create(
                                      work_id: event.work_id,
                                      source_id: event.source_id,
                                      total: item.fetch("total", 0),
                                      pdf: item.fetch("pdf", 0),
                                      html: item.fetch("html", 0),
                                      readers: item.fetch("readers", 0),
                                      comments: item.fetch("comments", 0),
                                      likes: item.fetch("likes", 0)) }
  end

  def send_callback
    data = { "deposit" => {
             "id" => uuid,
             "state" => state,
             "message_type" => message_type,
             "message_action" => message_action,
             "source_token" => source_token,
             "timestamp" => timestamp }}
    get_result(callback, data: data.to_json, token: ENV['API_KEY'])
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
    write_attribute(:occured_at, Time.zone.now.utc) if occured_at.blank?
  end
end
