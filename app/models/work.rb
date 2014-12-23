require 'cgi'
require 'addressable/uri'
require "builder"

class Work < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  belongs_to :publisher, primary_key: :member_id
  belongs_to :work_type
  has_many :retrieval_statuses, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses

  validates :pid_type, :pid, :title, presence: true
  validates :doi, uniqueness: true, format: { with: DOI_FORMAT }, allow_nil: true
  validates :canonical_url, uniqueness: true, format: { with: URL_FORMAT }, allow_nil: true
  validates :pid, :pmid, :pmcid, uniqueness: true, allow_nil: true
  validates :year, numericality: { only_integer: true }
  validate :validate_published_on

  before_validation :sanitize_title, :normalize_url, :set_pid
  after_create :create_retrievals

  scope :query, ->(query) { where("doi like ?", "#{query}%") }
  scope :last_x_days, ->(duration) { where("published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :has_events, -> { includes(:retrieval_statuses)
    .where("retrieval_statuses.event_count > ?", 0)
    .references(:retrieval_statuses) }
  scope :by_source, ->(source_id) { joins(:retrieval_statuses)
    .where("retrieval_statuses.source_id = ?", source_id) }

  serialize :csl, JSON

  # this is faster than first_or_create
  def self.find_or_create(params)
    self.create!(params)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    # update title and/or date if work exists
    # raise an error for other RecordInvalid errors such as missing title
    if e.message.start_with?("Validation failed: Doi has already been taken") || e.message.include?("key 'index_works_on_doi'")
      work = Work.where(doi: params[:doi]).first
      work.update_attributes(params.except(:canonical_url)) unless work.nil?
      work
    elsif e.message.start_with?("Validation failed: Canonical url has already been taken") || e.message.include?("key 'index_works_on_url'")
      work = Work.where(canonical_url: params[:canonical_url]).first
      work.update_attributes(params.except(:canonical_url)) unless work.nil?
      work
    elsif params[:doi].present?
      Alert.create(:exception => "",
                   :class_name => "ActiveRecord::RecordInvalid",
                   :message => "#{e.message} for doi #{params[:doi]}.",
                   :target_url => "http://dx.doi.org/#{params[:doi]}")
      nil
    else
      Alert.create(:exception => "",
                   :class_name => "ActiveRecord::RecordInvalid",
                   :message => "#{e.message} for url #{params[:canonical_url]}.",
                   :target_url => params[:canonical_url])
      nil
    end
  end

  def self.per_page
    50
  end

  def self.count_all
    if ActionController::Base.perform_caching
      status_update_date = Rails.cache.read('status:timestamp')
      Rails.cache.read("status/works_count/#{status_update_date}").to_i
    else
      Work.count
    end
  end

  def self.queue_work_delete(publisher_id)
    if publisher_id == "all"
      delay(priority: 2, queue: "work-delete-queue").destroy_all
    elsif publisher_id.present?
      delay(priority: 2, queue: "work-delete-queue")
        .destroy_all(publisher_id: publisher_id)
    end
  end

  # def url
  #   case pid_type
  #   when "doi" then "http://dx.doi.org/#{doi}"
  #   when "pmic" then "http://www.ncbi.nlm.nih.gov/pubmed/#{pmid}"
  #   when "pmcid" then "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{pmcid}"
  #   end
  # end

  def to_param
    "#{pid_type}/#{pid}"
  end

  def events_count
    @events_count ||= retrieval_statuses.reduce(0) { |sum, r| sum + r.event_count }
  end

  def pid_escaped
    CGI.escape(pid) if pid.present?
  end

  def doi_escaped
    CGI.escape(doi) if doi.present?
  end

  def doi_as_url
    Addressable::URI.encode("http://dx.doi.org/#{doi}")  if doi.present?
  end

  def doi_prefix
    doi[/^10\.\d{4,5}/]
  end

  def query_string
    return nil unless doi.present? || canonical_url.present?

    [doi, canonical_url].reject { |i| i.nil? }.map { |i| "\"#{i}\"" }.join("+OR+")
  end

  def get_url
    return true if canonical_url.present?
    return false unless doi.present?

    url = get_canonical_url(doi_as_url, work_id: id)

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

    result = get_persistent_identifiers(doi)
    return true if result.blank?

    # remove PMC prefix
    result['pmcid'] = result['pmcid'][3..-1] if result['pmcid']

    new_ids = missing_ids.reduce({}) do |hash, (k, v)|
      val = result[k.to_s]
      hash[k] = val if val.present? && val != "0"
      hash
    end
    return true if new_ids.empty?

    update_attributes(new_ids)
  end

  def all_urls
    urls = []
    urls << doi_as_url if doi.present?
    urls << canonical_url if canonical_url.present?
    urls
  end

  def canonical_url_escaped
    CGI.escape(canonical_url)
  end

  def title_escaped
    CGI.escape(title.to_str).gsub("+", "%20")
  end

  def signposts
    @signposts ||= sources.pluck(:name, :event_count, :events_url)
  end

  def event_count(name)
    signposts.reduce(0) { |sum, source| source[0] == name ? source[1].to_i : sum }
  end

  def events_url(name)
    signposts.reduce(nil) { |sum, source| source[0] == name ? source[2] : sum }
  end

  def mendeley_url
    @mendeley_url ||= events_url("mendeley")
  end

  def citeulike_url
    @citeulike_url ||= events_url("citeulike")
  end

  def views
    @views || event_count("pmc") + event_count("counter")
  end

  def shares
    @shares ||= event_count("facebook") + event_count("twitter") + event_count("twitter_search")
  end

  def bookmarks
    @bookmarks ||= event_count("citeulike") + event_count("mendeley")
  end

  def citations
    @citations ||= Source.installed.where(name: "scopus").first ? event_count("scopus") : event_count("crossref")
  end

  alias_method :viewed, :views
  alias_method :saved, :bookmarks
  alias_method :discussed, :shares
  alias_method :cited, :citations

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

  def update_date_parts
    return nil unless published_on

    write_attribute(:year, published_on.year)
    write_attribute(:month, published_on.month)
    write_attribute(:day, published_on.day)
  end

  def update_date
    updated_at.nil? ? nil : updated_at.utc.iso8601
  end

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
    self.title = ActionController::Base.helpers.sanitize(title)
  end

  def normalize_url
    return nil if canonical_url.blank?

    url = get_normalized_url(canonical_url)
    if url.is_a?(Hash)
      self.canonical_url = canonical_url
      errors.add :canonical_url, url.fetch(:error)
    else
      self.canonical_url = url
    end
  end

  # pid is required, use doi, pmid, pmcid, or canonical url in that order
  def set_pid
    if doi.present?
      write_attribute(:pid, doi)
      write_attribute(:pid_type, "doi")
    elsif pmid.present?
      write_attribute(:pid, pmid)
      write_attribute(:pid_type, "pmid")
    elsif pmcid.present?
      write_attribute(:pid, "PMC#{pmcid}")
      write_attribute(:pid_type, "pmcid")
    elsif canonical_url.present?
      write_attribute(:pid, canonical_url)
      write_attribute(:pid_type, "url")
    else
      errors.add :doi, "must provide at least one persistent identifier"
    end
  end

  def create_retrievals
    # Create an empty retrieval record for every installed source for the new work
    Source.installed.each do |source|
      RetrievalStatus.where(work_id: id, source_id: source.id).first_or_create
    end
  end
end
