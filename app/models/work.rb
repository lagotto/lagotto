require 'cgi'
require 'addressable/uri'
require "builder"

class Work < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  # include author methods
  include Authorable

  # include date methods
  include Dateable

  # include methods for calculating metrics
  include Measurable

  # store blank values as nil
  nilify_blanks

  belongs_to :publisher, primary_key: :member_id
  belongs_to :work_type
  has_many :events, dependent: :destroy
  has_many :sources, :through => :events
  has_many :notifications, :dependent => :destroy
  has_many :api_responses
  has_many :relations
  has_many :reference_relations, -> { where "level > 0" }, class_name: 'Relation', :dependent => :destroy
  has_many :version_relations, -> { where "level = 0" }, class_name: 'Relation', :dependent => :destroy
  has_many :references, :through => :reference_relations, source: :work
  has_many :versions, :through => :version_relations

  validates :pid, :title, presence: true
  validates :doi, uniqueness: true, format: { with: DOI_FORMAT }, case_sensitive: false, allow_blank: true
  validates :canonical_url, uniqueness: true, format: { with: URL_FORMAT }, allow_blank: true
  validates :ark, uniqueness: true, format: { with: ARK_FORMAT }, allow_blank: true
  validates :pmid, :pmcid, :arxiv, :wos, :scp, uniqueness: true, allow_blank: true
  validates :year, numericality: { only_integer: true }
  validate :validate_published_on

  before_validation :set_metadata, :sanitize_title, :normalize_url

  scope :query, ->(query) { where("pid like ?", "#{query}%") }
  scope :last_x_days, ->(duration) { where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :has_events, -> { includes(:events).where("events.total > ?", 0).references(:events) }
  scope :by_source, ->(source_id) { joins(:events).where("events.source_id = ?", source_id) }

  scope :tracked, -> { where("works.tracked = ?", true) }

  serialize :csl, JSON

  def self.find_or_create(params)
    work = Work.where(pid: params.fetch(:pid, nil)).first_or_create(params.except(:pid, :source_id, :relation_type_id, :related_works))
    work.update_relations(params.fetch(:related_works, []))
    work
  end

  def update_relations(data)
    Array(data).map do |item|
      # mix symbol and string keys
      item = item.with_indifferent_access
      pid = item.fetch(:pid, nil)
      next unless pid.present?

      id_hash = get_id_hash(pid)
      item = item.merge(id_hash)

      source = Source.where(name: item.fetch(:source_id)).first
      relation_name = item.fetch(:relation_type_id, "is_referenced_by")
      relation_type = RelationType.where(name: relation_name).first
      # recursion for nested related_works
      related_work = Work.find_or_create(item)

      unless related_work.persisted?
        message = "No metadata for #{pid} found"
        Notification.where(message: message).where(unresolved: true).first_or_create(
          class_name: "Net::HTTPNotFound",
          target_url: pid)
        next
      end

      next unless relation_type.present? && source.present?
      inverse_relation_type = RelationType.where(name: relation_type.inverse_name).first
      next unless inverse_relation_type.present?

      Relation.where(work_id: id,
                     related_work_id: related_work.id,
                     source_id: source.id).first_or_create(
                       relation_type_id: relation_type.id,
                       level: relation_type.level)
      Relation.where(work_id: related_work.id,
                     related_work_id: id,
                     source_id: source.id).first_or_create(
                       relation_type_id: inverse_relation_type.id,
                       level: inverse_relation_type.level)
    end
  end

  def self.per_page
    50
  end

  def self.count_all
    Status.first && Status.first.works_count
  end

  def to_param
    pid
  end

  def events_count
    @events_count ||= events.reduce(0) { |sum, r| sum + r.total }
  end

  def pid_escaped
    CGI.escape(pid) if pid.present?
  end

  def doi_escaped
    CGI.escape(doi) if doi.present?
  end

  def dataone_escaped
    dataone.gsub(/\:/, '\:')  if dataone.present?
  end

  def doi_prefix
    doi[/^10\.\d{4,5}/]
  end

  def get_url
    return true if canonical_url.present?
    return false unless doi.present?

    url = get_canonical_url(pid, work_id: id)

    if url.present? && url.is_a?(String)
      update_attributes(:canonical_url => url)
    else
      false
    end
  end

  # call Pubmed API to get missing identifiers
  # update work if we find a new identifier
  def get_ids
    ids = { doi: doi, pmid: pmid, pmcid: pmcid }
    missing_ids = ids.reject { |k, v| v.present? }
    return true if missing_ids.empty?

    existing_ids = ids.select { |k, v| v.present? }
    key, value = existing_ids.first
    result = get_persistent_identifiers(value, key)

    if result.present? && result.is_a?(Hash)
      # remove PMC prefix
      result['pmcid'] = result['pmcid'][3..-1] if result['pmcid']

      new_ids = missing_ids.reduce({}) do |hsh, (k, v)|
        val = result[k.to_s]
        hsh[k] = val if val.present? && val != "0"
        hsh
      end
      update_attributes(new_ids)
    else
      false
    end
  end

  def all_urls
    [canonical_url, pmid_as_europepmc_url].compact
  end

  def pmid_as_europepmc_url
    "http://europepmc.org/abstract/MED/#{pmid}" if pmid.present?
  end

  def canonical_url_escaped
    CGI.escape(canonical_url)
  end

  def title_escaped
    CGI.escape(title.to_str).gsub("+", "%20")
  end

  def signposts
    @signposts ||= sources.pluck(:name, :total, :events_url)
  end

  def events_urls
    signposts.map { |source| source[2] }.compact
  end

  def event_count(name)
    signposts.reduce(0) { |sum, source| source[0] == name ? source[1].to_i : sum }
  end

  def event_counts(names)
    names.reduce(0) { |sum, source| sum + event_count(source) }
  end

  def events_url(name)
    signposts.reduce(nil) { |sum, source| source[0] == name ? source[2] : sum }
  end

  def scopus_url
    @scopus_url ||= events_url("scopus")
  end

  def wos_url
    @wos_url ||= events_url("wos")
  end

  def mendeley_url
    @mendeley_url ||= events_url("mendeley")
  end

  def orcid
    Array(/^http:\/\/orcid\.org\/(.+)/.match(canonical_url)).last
  end

  def github
    Array(/^https:\/\/github\.com\/(.+)\/(.+)/.match(canonical_url)).last
  end

  def github_release
    Array(/^https:\/\/github\.com\/(.+)\/(.+)\/tree\/(.+)/.match(canonical_url)).last
  end

  def github_owner
    Array(/^https:\/\/github\.com\/(.+)/.match(canonical_url)).last
  end

  def views
    names = ENV["VIEWED"] ? ENV["VIEWED"].split(",") : ["pmc", "counter"]
    @views || event_counts(names)
  end

  def shares
    names = ENV["DISCUSSED"] ? ENV["DISCUSSED"].split(",") : ["facebook", "twitter", "twitter_search"]
    @shares ||= event_counts(names)
  end

  def bookmarks
    names = ENV["SAVED"] ? ENV["SAVED"].split(",") : ["citeulike", "mendeley"]
    @bookmarks ||= event_counts(names)
  end

  def citations
    name = ENV["CITED"] ? ENV["CITED"] : "crossref"
    @citations ||= event_count(name)
  end

  alias_method :viewed, :views
  alias_method :saved, :bookmarks
  alias_method :discussed, :shares
  alias_method :cited, :citations

  def metrics
    sources.pluck(:name, :total)
  end

  def issued
    { "date-parts" => [[year, month, day].reject(&:blank?)] }
  end

  def issued_date
    date_parts = issued["date-parts"].first
    date = Date.new(*date_parts)

    case date_parts.length
    when 1 then date.strftime("%Y")
    when 2 then date.strftime("%B %Y")
    when 3 then date.strftime("%B %-d, %Y")
    end
  end

  def author
    csl.present? ? csl["author"] : nil
  end

  def container_title
    csl.present? ? csl["container-title"] : nil
  end

  def volume
    csl.present? ? csl["volume"] : nil
  end

  def page
    csl.present? ? csl["page"] : nil
  end

  def issue
    csl.present? ? csl["issue"] : nil
  end

  def update_date_parts
    return nil unless published_on

    write_attribute(:year, published_on.year)
    write_attribute(:month, published_on.month)
    write_attribute(:day, published_on.day)
  end

  def timestamp
    updated_at.utc.iso8601
  end

  alias_method :update_date, :timestamp

  private

  # Use values from year, month, day for published_on
  # Uses  "01" for month and day if they are missing
  def validate_published_on
    date_parts = [year, month, day].reject(&:blank?)
    published_on = Date.new(*date_parts)
    if published_on > Time.zone.now.to_date
      errors.add :published_on, "is a date in the future"
    elsif published_on < Date.new(1650)
      errors.add :published_on, "is before 1650"
    else
      write_attribute(:published_on, published_on)
    end
  rescue ArgumentError
    errors.add :published_on, "is not a valid date"
  end

  def sanitize_title
    self.title = ActionController::Base.helpers.sanitize(title, tags: %w(b i sc sub sup))
  end

  def normalize_url
    return nil if canonical_url.blank?

    url = get_normalized_url(canonical_url)

    if url.is_a?(Hash)
      self.canonical_url = canonical_url
      errors.add :canonical_url, url.fetch(:error)
    elsif url !~ /^(http|https)/
      errors.add :canonical_url, "only http and https URLs are supported"
    else
      self.canonical_url = url
    end
  end

  # collect missing metadata for doi, pmid, orcid, github
  def set_metadata
    return if registration_agency.present? && title.present? && year.present?

    if doi.present?
      ra = registration_agency || get_doi_ra(doi)
      return nil unless ra.present?

      write_attribute(:registration_agency, ra)
      write_attribute(:tracked, true)
      metadata = get_metadata(doi, ra)
    elsif orcid.present?
      write_attribute(:registration_agency, "orcid")
      write_attribute(:tracked, false)
      metadata = get_metadata(orcid, "orcid")
    elsif github_release.present?
      write_attribute(:registration_agency, "github")
      write_attribute(:tracked, false)
      metadata = get_metadata(canonical_url, "github_release")
    elsif github.present?
      write_attribute(:registration_agency, "github")
      write_attribute(:tracked, true)
      metadata = get_metadata(canonical_url, "github")
    elsif github_owner.present?
      write_attribute(:registration_agency, "github")
      write_attribute(:tracked, false)
      metadata = get_metadata(canonical_url, "github_owner")
    else
      return nil
    end

    write_metadata(metadata)
  end

  def write_metadata(metadata)
    csl = {
      "author" => metadata.fetch("author", []),
      "container-title" => metadata.fetch("container-title", nil),
      "volume" => metadata.fetch("volume", nil),
      "page" => metadata.fetch("page", nil),
      "issue" => metadata.fetch("issue", nil) }

    type = metadata.fetch("type", nil)
    work_type_id = WorkType.where(name: type).pluck(:id).first

    date_parts = Array(metadata.fetch("issued", {}).fetch("date-parts", []).first)
    year, month, day = date_parts[0], date_parts[1], date_parts[2]

    write_attribute(:csl, csl)
    write_attribute(:title, metadata.fetch("title", nil))
    write_attribute(:publisher_id, metadata.fetch("publisher_id", nil))
    write_attribute(:year, year)
    write_attribute(:month, month)
    write_attribute(:day, day)
    write_attribute(:work_type_id, work_type_id)
  end
end
