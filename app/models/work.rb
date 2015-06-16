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

  # store blank values as nil
  nilify_blanks

  belongs_to :publisher, primary_key: :member_id
  belongs_to :work_type
  has_many :retrieval_statuses, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses
  has_many :alerts, :dependent => :destroy
  has_many :api_responses
  has_many :relations
  has_many :reference_relations, -> { where "level > 0" }, class_name: 'Relation', :dependent => :destroy
  has_many :version_relations, -> { where "level = 0" }, class_name: 'Relation', :dependent => :destroy
  has_many :references, :through => :reference_relations, source: :work
  has_many :versions, :through => :version_relations

  validates :pid_type, :pid, :title, presence: true
  validates :doi, uniqueness: true, format: { with: DOI_FORMAT }, allow_blank: true
  validates :canonical_url, uniqueness: true, format: { with: URL_FORMAT }, allow_blank: true
  validates :ark, uniqueness: true, format: { with: ARK_FORMAT }, allow_blank: true
  validates :pid, :pmid, :pmcid, :arxiv, :wos, :scp, uniqueness: true, allow_blank: true
  validates :year, numericality: { only_integer: true }
  validate :validate_published_on

  before_validation :sanitize_title, :normalize_url, :set_pid
  after_create :create_retrievals, if: :tracked

  scope :query, ->(query) { where("pid like ?", "#{query}%") }
  scope :last_x_days, ->(duration) { where("created_at > ?", Time.zone.now.beginning_of_day - duration.days) }
  scope :has_events, -> { includes(:retrieval_statuses)
    .where("retrieval_statuses.total > ?", 0)
    .references(:retrieval_statuses) }
  scope :by_source, ->(source_id) { joins(:retrieval_statuses)
    .where("retrieval_statuses.source_id = ?", source_id) }
  scope :tracked, -> { where("works.tracked = ?", true) }

  serialize :csl, JSON

  # this is faster than first_or_create
  def self.find_or_create(params)
    work = self.create!(params.except(:related_works))
    work.update_relations(params.fetch(:related_works, []))
    work
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    # update work if work exists
    # raise an error for other RecordInvalid errors such as missing title
    if e.message.include?("Doi has already been taken") || e.message.include?("key 'index_works_on_doi'")
      work = Work.where(doi: params[:doi]).first
      work.update_attributes(params.except(:pid, :doi)) if work.present? && params[:tracked]
      work.update_relations(params.fetch(:related_works, [])) if work.present?
      work
    elsif e.message.include?("Pmid has already been taken") || e.message.include?("key 'index_works_on_pmid'")
      work = Work.where(pmid: params[:pmid]).first
      work.update_attributes(params.except(:pid, :pmid)) if work.present? && params[:tracked]
      work.update_relations(params.fetch(:related_works, [])) if work.present?
      work
    elsif e.message.include?("Pid has already been taken") || e.message.include?("key 'index_works_on_pid'")
      work = Work.where(canonical_url: params[:canonical_url]).first
      work.update_attributes(params.except(:pid, :canonical_url)) if work.present? && params[:tracked]
      work.update_relations(params.fetch(:related_works, [])) if work.present?
      work
    else
      if params[:doi].present?
        target_url = "http://doi.org/#{params[:doi]}"
        message = "#{e.message} for doi #{params[:doi]}."
      elsif params[:pmid].present?
        target_url = "http://www.ncbi.nlm.nih.gov/pubmed/#{params[:pmid]}"
        message = "#{e.message} for pmid #{params[:pmid]}."
      else
        target_url = params[:canonical_url]
        message = "#{e.message} for url #{target_url}."
      end

      Alert.where(message: message).where(unresolved: true).first_or_create(
        :exception => "",
        :class_name => "ActiveRecord::RecordInvalid",
        :target_url => target_url)
      nil
    end
  end

  def update_relations(data)
    Array(data).map do |item|
      related_work = Work.where(pid: item.fetch("related_work")).first
      source = Source.where(name: item.fetch("source")).first
      relation_name = item.fetch("relation_type", "cited")
      relation_type = RelationType.where(name: relation_name).first

      next unless relation_type.present?
      inverse_relation_type = RelationType.where(name: relation_type.inverse_name).first
      next unless related_work.present? && source.present? && inverse_relation_type.present?

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
    @events_count ||= retrieval_statuses.reduce(0) { |sum, r| sum + r.total }
  end

  def pid_escaped
    CGI.escape(pid) if pid.present?
  end

  def doi_escaped
    CGI.escape(doi) if doi.present?
  end

  def doi_as_url
    Addressable::URI.encode("http://doi.org/#{doi}") if doi.present?
  end

  def pmid_as_url
    "http://www.ncbi.nlm.nih.gov/pubmed/#{pmid}" if pmid.present?
  end

  def pmid_as_europepmc_url
    "http://europepmc.org/abstract/MED/#{pmid}" if pmid.present?
  end

  def pmcid_as_url
    "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{pmcid}/" if pmcid.present?
  end

  def ark_as_url
    "http://n2t.net/#{ark}" if ark.present?
  end

  def doi_prefix
    doi[/^10\.\d{4,5}/]
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

  def url
    doi_as_url.presence || pmid_as_url.presence || canonical_url
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
    else
      self.canonical_url = url
    end
  end

  # pid is required, use doi, pmid, pmcid, arxiv, wos, scp or canonical url in that order
  def set_pid
    if doi.present?
      write_attribute(:pid, "doi:#{doi}")
      write_attribute(:pid_type, "doi")
    elsif pmid.present?
      write_attribute(:pid, "pmid:#{pmid}")
      write_attribute(:pid_type, "pmid")
    elsif pmcid.present?
      write_attribute(:pid, "pmcid:PMC#{pmcid}")
      write_attribute(:pid_type, "pmcid")
    elsif arxiv.present?
      write_attribute(:pid, "arxiv:#{arxiv}")
      write_attribute(:pid_type, "arxiv")
    elsif wos.present?
      write_attribute(:pid, "wos:#{wos}")
      write_attribute(:pid_type, "wos")
    elsif scp.present?
      write_attribute(:pid, "scp:#{scp}")
      write_attribute(:pid_type, "scp")
    elsif ark.present?
      write_attribute(:pid, ark)
      write_attribute(:pid_type, "ark")
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
