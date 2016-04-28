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
  belongs_to :registration_agency
  belongs_to :work_type
  has_many :results, inverse_of: :work
  has_many :sources, :through => :results
  has_many :notifications, :dependent => :destroy
  has_many :api_responses
  has_many :relations, dependent: :destroy
  has_many :inverse_relations, class_name: "Relation", foreign_key: "related_work_id", dependent: :destroy
  has_many :related_works, :through => :relations, source: :work
  has_many :contributions
  has_many :contributors, :through => :contributions
  has_many :deposits, inverse_of: :work

  validates :pid, :title, :issued_at, presence: true
  validates :doi, uniqueness: true, format: { with: DOI_FORMAT }, case_sensitive: false, allow_blank: true
  validates :canonical_url, uniqueness: true, format: { with: URL_FORMAT }, allow_blank: true
  validates :ark, uniqueness: true, format: { with: ARK_FORMAT }, allow_blank: true
  validates :pmid, :pmcid, :arxiv, :wos, :scp, uniqueness: true, allow_blank: true
  validates :year, numericality: { only_integer: true }
  validate :validate_published_on
  validates_datetime :issued_at, on_or_before: lambda { Time.zone.now }

  before_validation :set_metadata, :sanitize_title, :normalize_url

  scope :query, ->(query) { where(doi: query) }
  scope :last_x_days, ->(duration) { where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :has_results, -> { includes(:results).where("results.total > ?", 0).references(:results) }
  scope :by_source, ->(source_id) { joins(:results).where("results.source_id = ?", source_id) }

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
    @events_count ||= results.reduce(0) { |sum, r| sum + r.total }
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

  def prefix
    doi[/^10\.\d{4,5}/] if doi.present?
  end

  def get_url
    return true if canonical_url.present?
    return false unless doi.present?

    _handle_url = get_handle_url(doi_as_url(doi), work_id: id)
    _canonical_url = get_canonical_url(doi_as_url(doi), work_id: id)

    if _canonical_url.is_a?(String) && _handle_url.is_a?(String)
      update_attributes(canonical_url: _canonical_url,
                        handle_url: _handle_url)
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

  def provenance_urls
    relations.where.not(provenance_url: nil).pluck(:provenance_url)
  end

  def provenance_url(name)
    source = cached_source(name)
    return nil unless source.present?

    relations.where(source_id: source.id).pluck(:provenance_url).first
  end

  def scopus_url
    @scopus_url ||= provenance_url("scopus")
  end

  def wos_url
    @wos_url ||= provenance_url("wos")
  end

  def mendeley_url
    @mendeley_url ||= provenance_url("mendeley")
  end

  def result_counts(names)
    names.reduce(0) { |sum, source| sum + result_count(source) }
  end

  def result_count(name)
    source = cached_source(name)
    return 0 unless source.present?

    results.where(source_id: source.id).pluck(:total).first
  end

  # returns hash with source names as keys and aggregated total for each source as values
  def metrics
    results.group(:source_id).sum(:total).map { |r| [cached_source_names[r[0]], r[1]] }.to_h
  end

  def published
    get_date_from_parts(year, month, day)
  end

  def issued_date
    date_parts = [year, month, day].compact
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
    self.published_on = Date.new(*date_parts)
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
    return if pid.present? && title.present? && issued_at.present?

    id_hash = get_id_hash(pid)

    if id_hash[:doi].present?
      if registration_agency_id.nil?
        # get_doi_ra returns hash with keys :id, :name, :title
        ra = get_doi_ra(id_hash[:doi])
        return nil if ra.nil? || ra[:error]

        self.registration_agency_id = ra[:id]
      end

      return nil unless registration_agency.present?

      tracked = true
      metadata = get_metadata(id_hash[:doi], registration_agency[:name])
    elsif id_hash[:canonical_url].present? && github_release_from_url(id_hash[:canonical_url]).present?
      tracked = false
      metadata = get_metadata(id_hash[:canonical_url], "github_release")
    elsif id_hash[:canonical_url].present? && github_repo_from_url(id_hash[:canonical_url]).present?
      registration_agency = cached_registration_agency("github") unless registration_agency.present?
      tracked = true
      metadata = get_metadata(id_hash[:canonical_url], "github")
    else
      return nil
    end

    return if metadata[:error].present?
    write_metadata(metadata, registration_agency, tracked)
  end

  def write_metadata(metadata, registration_agency, tracked)
    self.registration_agency = registration_agency
    self.tracked = tracked

    self.csl = {
      "author" => metadata.fetch("author", []),
      "container-title" => metadata.fetch("container-title", nil),
      "volume" => metadata.fetch("volume", nil),
      "page" => metadata.fetch("page", nil),
      "issue" => metadata.fetch("issue", nil) }

    type = metadata.fetch("type", nil)
    self.work_type_id = WorkType.where(name: type).pluck(:id).first

    publisher = metadata.fetch("publisher_id", nil)
    self.publisher_id = Publisher.where(name: publisher).pluck(:id).first

    if metadata["published"].present?
      self.year, self.month, self.day = get_year_month_day(metadata.fetch("published", nil))
    else
      self.year, self.month, self.day = get_year_month_day(metadata.fetch("issued", nil))
    end

    self.issued_at = get_datetime_from_iso8601(metadata.fetch("issued", nil))

    self.title = metadata.fetch("title", nil)

    self.doi = metadata.fetch("DOI", nil)
    self.canonical_url = metadata.fetch("URL", nil)
  end
end
