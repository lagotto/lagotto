class Deposit < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  # include helper module for extracting identifier
  include Identifiable

  # include helper module for query caching
  include Cacheable

  # include date methods
  include Dateable

  belongs_to :work, inverse_of: :deposits, autosave: true
  belongs_to :related_work, class_name: "Work", inverse_of: :deposits, autosave: true
  belongs_to :contributor, inverse_of: :deposits, autosave: true
  belongs_to :source, primary_key: :name, inverse_of: :deposits
  belongs_to :relation_type, primary_key: :name, inverse_of: :deposits
  has_many :notifications

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

    # Reset after failure.
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
  validates_associated :relation_type

  scope :query, ->(query) { where(uuid: query) }

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

  def queue_deposit_job
    DepositJob.set(wait: 3.minutes).perform_later(self)
  end

  def to_param  # overridden, use uuid instead of id
    uuid
  end

  def process_data
    self.start

    if collect_data
      self.finish
    else
      self.error
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

  def source
    cached_source(source_id)
  end

  def publisher
    cached_publisher(publisher_id)
  end

  def relation_type
    cached_relation_type(relation_type_id)
  end

  def inv_relation_type
    cached_inv_relation_type(relation_type_id)
  end

  def year
    occurred_at.year
  end

  def month
    occurred_at.month
  end

  # update in order, stop if an error occured
  def update_relations
    update_work &&
    update_related_work &&
    update_relation &&
    update_inv_relation
  end

  def update_contributions
    update_contributor && update_related_work && update_contribution
  end

  def update_work
    pid = normalize_pid(subj_id)
    item = from_csl(subj)

    # initialize work if it doesn't exist
    self.work = Work.where(pid: pid).first_or_initialize

    # update all attributes
    self.work.assign_attributes(item)

    # save deposit and work (thanks to autosave option) to the database
    self.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError => exception
    if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
      self.work = Work.where(pid: pid).first
    else
      handle_exception(exception, class_name: "work", id: pid, target_url: pid)
    end
  end

  def update_related_work
    return true unless obj_id.present?

    pid = normalize_pid(obj_id)
    item = from_csl(obj)

    # initialize related_work if it doesn't exist
    self.related_work = Work.where(pid: pid).first_or_initialize

    # update all attributes
    self.related_work.assign_attributes(item)

    # save deposit and related_work (thanks to autosave option) to the database
    self.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError => exception
    if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
      self.related_work = Work.where(pid: pid).first
    else
      handle_exception(exception, class_name: "related_work", id: pid, target_url: pid)
    end
  end

  def update_relation
    result = Result.where(work_id: related_work_id,
                                    source_id: source.id).first_or_create

    m = Month.where(work_id: related_work_id,
                    source_id: source.id,
                    result_id: result.id,
                    year: year,
                    month: month).first_or_create

    r = Relation.where(work_id: work_id,
                       related_work_id: related_work_id,
                       source_id: source.id,
                       month_id: m.id)
                .first_or_initialize

    # update all attributes
    r.assign_attributes(relation_type_id: relation_type.present? ? relation_type.id : nil,
                        publisher_id: publisher.present? ? publisher.id : nil,
                        total: total,
                        occurred_at: occurred_at)
    r.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
    if exception.class == ActiveRecord::RecordNotUnique
      Relation.where(work_id: work_id,
                     related_work_id: related_work_id,
                     source_id: source.id).first
    else
      handle_exception(exception, class_name: "relation", id: "#{subj_id}/#{obj_id}/#{source_id}")
    end
  end

  def update_inv_relation
    r = Relation.where(work_id: related_work_id,
                       related_work_id: work_id,
                       source_id: source.id)
                .first_or_initialize

    # update all attributes, return saved inv_relation
    r.assign_attributes(relation_type_id: inv_relation_type.present? ? inv_relation_type.id : nil,
                        publisher_id: publisher.present? ? publisher.id : nil,
                        total: total,
                        occurred_at: occurred_at,
                        implicit: true)
    r.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
    if exception.class == ActiveRecord::RecordNotUnique
      Relation.where(work_id: related_work_id,
                     related_work_id: work_id,
                     source_id: source.id).first
    else
      handle_exception(exception, class_name: "inv_relation", id: "#{subj_id}/#{obj_id}/#{source_id}")
    end
  end

  def update_contributor
    self.contributor = Contributor.where(pid: subj_id).first_or_initialize

    # save deposit and contributor (thanks to autosave option) to the database
    self.contributor.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError => exception
    if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
      self.contributor = Contributor.where(pid: subj_id).first
    else
      handle_exception(exception, class_name: "contributor", id: subj_id, target_url: subj_id)
    end
  end

  def update_contribution
    return true unless obj_id.present?

    c = Contribution.where(contributor_id: contributor_id,
                           work_id: related_work_id,
                           source_id: source.present? ? source.id : nil).first_or_initialize
    c.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
    handle_exception(exception, class_name: "contribution", id: "#{subj_id}/#{obj_id}/#{source_id}")
  end

  def update_publisher
    item = Publisher.from_csl(subj)
    p = Publisher.where(name: subj_id).first_or_initialize
    p.assign_attributes(item)
    p.save!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => exception
    if exception.class == ActiveRecord::RecordNotUnique || exception.message.include?("has already been taken") || exception.class == ActiveRecord::StaleObjectError
       Publisher.where(name: subj_id).first
    else
      handle_exception(exception, class_name: "publisher", id: subj_id)
    end
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
      tracked: item.fetch("tracked", nil),
      registration_agency: item.fetch("registration_agency", nil),
      csl: csl }.compact
  end

  def send_callback
    data = { "deposit" => {
               "id" => uuid,
               "state" => human_state_name,
               "errors" => error_messages,
               "message_type" => message_type,
               "message_action" => message_action,
               "source_token" => source_token,
               "total" => total,
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

  def handle_exception(exception, options={})
    message = "#{exception.message} for #{options[:class_name]} #{options[:id]}"
    Notification.create(exception: exception, message: message, target_url: options[:target_url], source_id: source.present? ? source.id : nil, deposit_id: id)

    write_attribute(:error_messages, { options[:class_name] => exception.message })

    false
  end
end
