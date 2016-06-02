class Contributor < ActiveRecord::Base
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

  has_many :contributions, :dependent => :destroy
  has_many :works, :through => :contributions
  has_many :contributor_roles, :through => :contributions
  has_many :deposits, inverse_of: :contributor
  belongs_to :user, primary_key: "orcid", foreign_key: "uid"

  validates :pid, presence: true, uniqueness: true
  validates :orcid, uniqueness: true, format: { with: ORCID_FORMAT }, allow_blank: true
  validates :github, uniqueness: true, allow_blank: true
  before_validation :set_metadata

  # after_commit :update_cache, :on => :create

  scope :order_by_name, -> { order("contributors.family_name") }
  scope :query, ->(query) { where("orcid = ? OR github = ? OR family_name LIKE ?", query, query, "%#{query}%") }

  def self.count_all
    Status.first && Status.first.contributors_count
  end

  def to_param  # overridden, use pid instead of id
    pid
  end

  def short_pid
    pid.gsub(/(http|https):\/+(\w+)/, '\2')
  end

  def credit_name
    if literal.present?
      literal
    elsif given_names.present? || family_name.present?
      [given_names, family_name].compact.join(' ')
    elsif orcid.present?
      orcid
    elsif github.present?
      github
    else
      "(:unas)"
    end
  end

  def work_count
    if ActionController::Base.perform_caching
      Rails.cache.read("contributor/#{pid}/work_count/#{timestamp}").to_i
    else
      works.size
    end
  end

  def work_count=(time)
    Rails.cache.write("contributor/#{pid}/work_count/#{time}",
                      works.size)
  end

  def work_count_by_source(source_id)
    if ActionController::Base.perform_caching
      Rails.cache.read("contributor/#{pid}/#{source_id}/work_count/#{timestamp}").to_i
    else
      works.has_results.by_source(source_id).size
    end
  end

  def work_count_by_source=(source_id, time)
    Rails.cache.write("contributor/#{pid}/#{source_id}/work_count/#{time}",
                      works.has_results.by_source(source_id).size)
  end

  def cache_key
    "contributor/#{pid}-#{timestamp}"
  end

  def timestamp
    cached_at.utc.iso8601
  end

  def update_cache
    CacheJob.perform_later(self)
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now

    send("work_count=", now.utc.iso8601)
    Source.active.each { |source| send("work_count_by_source=", source.id, now.utc.iso8601) }

    update_column(:cached_at, now)
  end

  # collect missing metadata for orcid
  def set_metadata
    return if orcid.present?

    self.orcid = orcid_from_url(pid) unless orcid.present?
    self.github = github_owner_from_url(pid) unless github.present?

    if orcid.present?
      metadata = get_metadata(orcid, "orcid")
    elsif github.present?
      metadata = get_metadata(github, "github_owner")
    else
      return nil
    end

    return if metadata[:error].present?

    author = metadata.fetch('author', []).first

    if author.is_a?(Hash)
      self.family_name = author.fetch('family', nil)
      self.given_names = author.fetch('given', nil)
      self.literal = author.fetch('literal', nil)
    elsif author.is_a?(String)
      self.literal = author
    end
  end
end
