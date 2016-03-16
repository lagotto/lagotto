class Deposit < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  # include helper module for query caching
  include Cacheable

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
  serialize :error_messages, JSON

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

  def process_data
    self.start
    if collect_data[:errors].present?
      write_attribute(:error_messages, collect_data[:errors])
      self.error
    else
      self.finish
    end
  end

  def collect_data
    case
    when message_type == "publisher" && message_action == "delete" then delete_publisher
    when message_type == "publisher" then update_publisher
    when message_type == "contribution" && message_action == "delete" then delete_contributor
    when message_type == "contribution" then update_contributions
    when message_type == "relation" && message_action == "delete" then delete_relation
    else update_relations
    end
  end

  def update_relations
    work = update_work(subj_id, subj)
    related_work = update_work(obj_id, obj)

    source = cached_source(source_id)
    source = source.present? ? { class: source.class.to_s, id: source.id, errors: [] } : { class: "Source", id: nil, errors: ["Source #{source_id} not found"] }

    relation_type = cached_relation_type(relation_type_id)
    relation_type = relation_type.present? ? { class: relation_type.class.to_s, id: relation_type.id, errors: [] } : { class: "RelationType", id: nil, errors: ["Relation type #{relation_type_id} not found"] }

    inv_relation_type = cached_inv_relation_type(relation_type_id)
    inv_relation_type = inv_relation_type.present? ? { class: inv_relation_type.class.to_s, id: inv_relation_type.id, errors: [] } : { class: "RelationType", id: nil, errors: ["Inverse relation type for #{relation_type_id} not found"] }

    relations = [work, related_work, source, relation_type, inv_relation_type]
    error_messages = relations.reduce([]) { |sum, item| sum + item[:errors] }
    return { errors: error_messages } if error_messages.present?

    relation = update_relation(work[:id], related_work[:id], source[:id], relation_type[:id])
    inv_relation = update_relation(related_work[:id], work[:id], source[:id], inv_relation_type[:id])

    relations += [relation, inv_relation]
    error_messages = relations.reduce([]) { |sum, item| sum + item[:errors] }
    { errors: error_messages }
  end

  def update_relation(work_id, related_work_id, source_id, rel_type_id)
    publisher = cached_publisher(publisher_id)
    publisher = publisher.id if publisher.present?

    relation = Relation.where(work_id: work_id, related_work_id: related_work_id, source_id: source_id).first_or_create(
      relation_type_id: rel_type_id
    )

    # update all attributes
    relation.update_attributes(relation_type_id: rel_type_id,
                               publisher_id: publisher,
                               total: total,
                               occurred_at: occurred_at)

    # update months
    months = [relation.get_events_current_month]
    update_months(relation, months)

    { class: relation.class.to_s, id: relation.id, errors: relation.errors.to_a }
  end

  def update_work(item_id, item)
    item = from_csl(item)

    # create work if it doesn't exist, filling out all required fields
    work = Work.where(pid: item_id).first_or_create(title: item.fetch("title", nil),
                                                    year: item.fetch("year", nil),
                                                    month: item.fetch("month", nil),
                                                    day: item.fetch("day", nil),
                                                    registration_agency: item.fetch("registration_agency", nil))

    # update all attributes
    work.update_attributes(item.except("pid", "title", "year", "month", "day", "registration_agency"))

    { class: work.class.to_s, id: work.id, errors: work.errors.to_a }
  end

  # convert CSL into format that the database understands
  # don't update nil values
  def from_csl(item)
    year, month, day = get_year_month_day(item.fetch("issued", nil))

    type = item.fetch("type", nil)
    work_type = cached_work_type(type) if type.present?
    work_type = work_type.present? ? work_type.id : nil

    csl = { "author" => item.fetch("author", []),
            "container-title" => item.fetch("container-title", nil),
            "volume" => item.fetch("volume", nil),
            "page" => item.fetch("page", nil),
            "issue" => item.fetch("issue", nil) }.compact

    { doi: item.fetch("DOI", nil),
      pmid: item.fetch("PMID", nil),
      pmcid: item.fetch("PMCID", nil),
      arxiv: item.fetch("arxiv", nil),
      ark: item.fetch("ark", nil),
      canonical_url: item.fetch("URL", nil),
      title: item.fetch("title", nil),
      year: year,
      month: month,
      day: day,
      work_type_id: work_type,
      tracked: item.fetch("tracked", false),
      registration_agency: item.fetch("registration_agency", nil),
      csl: csl }.compact
  end

  def update_contributions
    return {}

    Array(data).map do |item|
      # mix symbol and string keys
      item = item.with_indifferent_access
      pid = item.fetch(:pid, nil)
      next unless pid.present?

      source = Source.where(name: item.fetch(:source_id)).first

      # recursion for nested contributors
      contributor = Contributor.where(pid: pid).first_or_create

      unless contributor.persisted?
        message = "No metadata for #{pid} found"
        Notification.where(message: message).where(unresolved: true).first_or_create(
          class_name: "Net::HTTPNotFound",
          target_url: pid)
        next
      end

      begin
        Contribution.where(work_id: id,
                           contributor_id: contributor.id,
                           source_id: source.id).first_or_create
      rescue ActiveRecord::RecordNotUnique
        Contribution.where(work_id: id,
                           contributor_id: contributor.id,
                           source_id: source.id).first
      end
    end
  end

  def update_publisher
    publisher = Publisher.where(name: subj_id).first_or_create(title: subj["title"])
    publisher.update_attributes(title: subj["title"],
                                   registration_agency: subj["registration_agency"],
                                   active: subj["active"])

    { class: publisher.class.to_s, id: publisher.name, errors: publisher.errors.to_a }
  end

  def delete_relation
    work = Work.where(pid: subj_id).first
    related_work = Work.where(pid: obj_id).first
    source = Source.where(name: source_id).first

    return nil unless work.present? && related_work.present? && source.present?

    Relation.where(work_id: work.id, related_work_id: related_work.id, source_id: source.id).destroy_all
  end

  def delete_publisher
    Publisher.where(name: subj_id).destroy_all
  end

  def update_months(relation, months)
    months.map { |item| Month.where(relation_id: relation.id,
                                    month: item.fetch("month"),
                                    year: item.fetch("year")).first_or_create(
                                      work_id: relation.work_id,
                                      source_id: relation.source_id,
                                      total: item.fetch("total", 0)) }
  end

  def send_callback
    data = { "deposit" => {
               "id" => uuid,
               "state" => human_state_name,
               "errors" => error_messages,
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
    write_attribute(:total, 1) if total.blank?
    write_attribute(:relation_type_id, "references") if relation_type_id.blank?
    write_attribute(:occurred_at, Time.zone.now.utc) if occurred_at.blank?
  end
end
