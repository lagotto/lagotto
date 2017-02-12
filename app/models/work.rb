require 'cgi'
require 'addressable/uri'
require 'builder'

class Work < ActiveRecord::Base
  # include helper module for DOI resolution
  include Resolvable

  # include helper module for extracting identifier
  include Identifiable

  # include helper module to extract and generate metadata
  include Metadatable

  # include author methods
  include Authorable

  # include date methods
  include Dateable

  # include helper module for query caching
  include Cacheable

  # store blank values as nil
  nilify_blanks

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

  SCHEMA = "datacite"
  SCHEMA_VERSION = "4.0"

  def self.per_page
    50
  end

  def to_param  # overridden, use pid instead of id
    pid
  end

  def short_pid
    pid.gsub(/(http|https):\/+(\w+)/, '\2')
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

    urls = {}
    urls[:canonical_url] = get_canonical_url(doi_as_url(doi)).fetch(:url, nil)
    urls[:handle_url] = get_handle_url(doi_as_url(doi)).fetch(:url, nil)

    if urls.present?
      update_attributes(urls)
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

  def validate_xml
    self.xml = Date.new(*date_parts)
  rescue ArgumentError
    errors.add :xml, "is not valid xml"
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
        # get_doi_ra returns hash with keys :id, :title
        registration_agency = get_doi_ra(id_hash[:doi])
        return nil if registration_agency[:id].nil?
      end

      tracked = true
      metadata = get_metadata(id_hash[:doi], registration_agency[:id])
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
    write_metadata(metadata, registration_agency[:id], tracked)
  end

  def write_metadata(metadata, registration_agency_id, tracked)
    # write metadata XML
    datacite_metadata = metadata_for_datacite(metadata)
    datacite_work = datacite_xml(datacite_metadata)

    if datacite_work.validation_errors.body["errors"].present?
      self.xml = nil
    else
      self.xml = datacite_work.data
    end

    self.schema = SCHEMA
    self.schema_version = SCHEMA_VERSION

    self.registration_agency_id = registration_agency_id
    self.resource_type_id = metadata.fetch("resource_type_id", nil)
    self.publisher_id = metadata.fetch("publisher_id", nil)
    self.resource_type = metadata.fetch("resource_type", nil)
    self.tracked = tracked

    self.csl = {
      "author" => metadata.fetch("author", []),
      "container-title" => metadata.fetch("container-title", nil),
      "volume" => metadata.fetch("volume", nil),
      "page" => metadata.fetch("page", nil),
      "issue" => metadata.fetch("issue", nil) }

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
