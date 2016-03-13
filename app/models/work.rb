require 'cgi'
require 'addressable/uri'
require "builder"

class Work < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  # include helper module for extracting identifier
  include Identifiable

  # include author methods
  include Authorable

  # include date methods
  include Dateable

  # include methods for calculating metrics
  include Measurable

  # include helper module for query caching
  include Cacheable

  # store blank values as nil
  nilify_blanks

  belongs_to :publisher
  belongs_to :work_type
  has_many :sources, :through => :relations
  has_many :notifications, :dependent => :destroy
  has_many :api_responses
  has_many :relations, dependent: :destroy
  has_many :related_works, :through => :relations, source: :work
  has_many :contributions
  has_many :contributors, :through => :contributions

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
  scope :has_events, -> { includes(:relations).where("relations.total > ?", 0).references(:relations) }
  scope :by_source, ->(source_id) { joins(:relations).where("relations.source_id = ?", source_id) }

  scope :tracked, -> { where("works.tracked = ?", true) }

  serialize :csl, JSON

  def self.per_page
    50
  end

  def self.count_all
    Status.first && Status.first.works_count
  end

  def to_param  # overridden, use pid instead of id
    pid
  end

  def short_pid
    pid.gsub(/(http|https):\/+(\w+)/, '\2')
  end

  def events_count
    @events_count ||= relations.reduce(0) { |sum, r| sum + r.total }
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

    url = get_canonical_url(doi_as_url(doi), work_id: id)

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

  def viewed
    names = ENV["VIEWED"] ? ENV["VIEWED"].split(",") : ["pmc", "counter"]
    @viewed || event_counts(names)
  end

  def discussed
    names = ENV["DISCUSSED"] ? ENV["DISCUSSED"].split(",") : ["facebook", "twitter", "twitter_search"]
    @discussed ||= event_counts(names)
  end

  def saved
    names = ENV["SAVED"] ? ENV["SAVED"].split(",") : ["citeulike", "mendeley"]
    @saved ||= event_counts(names)
  end

  def cited
    name = ENV["CITED"] ? ENV["CITED"] : "crossref"
    @cited ||= event_count(name)
  end

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

  # collect missing metadata for doi, pmid, github
  def set_metadata
    return if registration_agency.present? && title.present? && year.present?

    id_hash = get_id_hash(pid)

    if id_hash[:doi].present?
      registration_agency ||= get_doi_ra(id_hash[:doi])
      return nil if registration_agency.nil? || registration_agency.is_a?(Hash)

      tracked = true
      metadata = get_metadata(id_hash[:doi], registration_agency)
    elsif id_hash[:canonical_url].present? && github_release(id_hash[:canonical_url]).present?
      registration_agency = "github"
      tracked = false
      metadata = get_metadata(canonical_url, "github_release")
    elsif id_hash[:canonical_url].present? && github_repo(id_hash[:canonical_url]).present?
      registration_agency = "github"
      tracked = true
      metadata = get_metadata(canonical_url, "github")
    elsif id_hash[:canonical_url].present? && github_owner(id_hash[:canonical_url]).present?
      registration_agency = "github"
      tracked = false
      metadata = get_metadata(canonical_url, "github_owner")
    else
      return nil
    end

    return if metadata[:error].present?
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

    publisher = metadata.fetch("publisher_id", nil)
    publisher_id = Publisher.where(name: publisher).pluck(:id).first

    date_parts = Array(metadata.fetch("issued", {}).fetch("date-parts", []).first)
    year, month, day = date_parts[0], date_parts[1], date_parts[2]

    title = metadata.fetch("title", nil)
  end
end
