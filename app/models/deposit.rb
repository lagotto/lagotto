class Deposit < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  before_create :create_uuid
  after_commit :queue_deposit_job, :on => :create

  state_machine :initial => :waiting do
    state :waiting, value: 0
    state :working, value: 1
    state :failed, value: 2
    state :done, value: 3

    after_transition :to => :done do |deposit|
      if deposit.callback.present?
        data = { "deposit" => {
                   "id" => deposit.uuid,
                   "state" => "done",
                   "message_type" => deposit.message_type,
                   "message_action" => deposit.message_action,
                   "message_size" => deposit.message_size,
                   "source_token" => deposit.source_token,
                   "timestamp" => Time.zone.now.iso8601
                 }
               }
        deposit.get_result(deposit.callback, data: data.to_json, token: ENV['API_KEY'])
      end
    end

    after_transition :to => :failed do |deposit|
      if deposit.callback.present?
        data = { "deposit" => {
                   "id" => deposit.uuid,
                   "state" => "failed",
                   "message_type" => deposit.message_type,
                   "message_action" => deposit.message_action,
                   "message_size" => 0,
                   "source_token" => deposit.source_token,
                   "timestamp" => Time.zone.now.iso8601
                 }
               }
        get_result(deposit.callback, data: data.to_json, token: ENV['API_KEY'])
      end

      Notification.create(:exception => "", :class_name => "StandardError",
                          :message => "Failed to process deposit #{deposit.uuid}.",
                          :level => Notification::FATAL)
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

  serialize :message, JSON

  validates :source_token, presence: true
  validates :message, presence: true

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

  # def perform_get_data(data)
  #   previous_total = total
  #   update_interval = retrieved_days_ago


  #   { total: total,
  #     html: html,
  #     pdf: pdf,
  #     previous_total: previous_total,
  #     skipped: skipped,
  #     update_interval: update_interval }
  # end

  def update_works
    message.fetch("works", []).map do |item|
      pid = item.fetch("pid", nil)
      doi = item.fetch("DOI", nil)
      pmid = item.fetch("PMID", nil)
      pmcid = item.fetch("PMCID", nil)
      arxiv = item.fetch("arxiv", nil)
      ark = item.fetch("ark", nil)
      canonical_url = item.fetch("URL", nil)

      title = item.fetch("title", nil)
      date_parts = item.fetch("issued", {}).fetch("date-parts", [[]]).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]
      type = item.fetch("type", nil)
      work_type_id = WorkType.where(name: type).pluck(:id).first
      registration_agency = item.fetch("registration_agency", nil)
      tracked = item.fetch("tracked", false)

      related_works = item.fetch("related_works", [])
      contributors = item.fetch("contributors", [])

      csl = {
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", nil),
        "volume" => item.fetch("volume", nil),
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil) }

      i = {
        pid: pid,
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
        csl: csl,
        related_works: related_works,
        contributors: contributors }

      w = Work.find_or_create(i)
      w ? w.pid : nil
    end
  end

  def update_events
    message.fetch("events", []).map do |item|
      source = Source.where(name: item.fetch("source_id", nil)).first
      work = Work.where(pid: item.fetch("work_id", nil)).first
      next unless source.present? && work.present?

      total = item.fetch("total", 0)

      # only create event row if we have at least one event
      if total > 0
        begin
          event = Event.where(source_id: source.id, work_id: work.id).first_or_create
        rescue ActiveRecord::RecordNotUnique
          event = Event.where(source_id: source.id, work_id: work.id).first
        end
      else
        event = Event.where(source_id: source.id, work_id: work.id).first
      end

      next unless event.present?

      event.update_attributes(retrieved_at: Time.zone.now,
                              total: total,
                              pdf: item.fetch("pdf", 0),
                              html: item.fetch("html", 0),
                              readers: item.fetch("readers", 0),
                              comments: item.fetch("comments", 0),
                              likes: item.fetch("likes", 0),
                              events_url: item.fetch("events_url", nil),
                              extra: item.fetch("extra", nil))

      months = item.fetch("months", [])
      months = [event.get_events_current_month] if months.blank?
      update_months(event, months)

      days = item.fetch("days", [])
      days = [event.get_events_current_day].compact if days.blank?
      update_days(event, days)

      event
    end
  end

  def update_contributors
    message.fetch("contributors", []).map do |item|
      Contributor.where(pid: item.fetch('pid', nil)).first_or_create
    end
  end

  def update_publishers
    message.fetch("publishers", []).map do |item|
      publisher = Publisher.where(name: item.fetch('name', nil)).first_or_create
      publisher.update_attributes(item.except('name'))
    end
  end

  def delete_events
    message.fetch("events", []).map do |item|
      Event.where(source_id: item.fetch('source_id', nil), work_id: item.fetch("work_id", nil)).destroy_all
    end
  end

  def delete_works
    message.fetch("works", []).map do |item|
      Work.where(pid: item.fetch('pid', nil)).destroy_all
    end
  end

  def delete_contributors
    message.fetch("contributors", []).map do |item|
      Contributor.where(pid: item.fetch('pid', nil)).destroy_all
    end
  end

  def delete_publishers
    message.fetch("publishers", []).map do |item|
      Publisher.where(name: item.fetch('name', nil)).destroy_all
    end
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

  def update_days(event, days)
    days.map { |item| Day.where(event_id: event.id,
                                day: item.fetch("day"),
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

  def message_size
    @message_size || message.fetch("works", []).size
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def cache_key
    "deposit/#{uuid}-#{timestamp}"
  end

  def create_uuid
    write_attribute(:uuid, SecureRandom.uuid) if uuid.blank?
    write_attribute(:message_type, 'default') if message_type.blank?
  end
end
