class Contributor < ActiveRecord::Base
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

  has_many :contributions
  has_many :works, :through => :contributions
  has_many :contributor_roles, :through => :contributions

  validates :pid, :presence => true, :uniqueness => true
  validates :orcid, :presence => true, :uniqueness => true
  before_validation :set_metadata

  after_commit :update_cache, :on => :create

  scope :order_by_name, -> { order("contributors.family_name") }
  scope :query, ->(query) { where("family_name like ?", "#{query}%") }

  def self.count_all
    Status.first && Status.first.contributors_count
  end

  def to_param  # overridden, use pid instead of id
    short_pid
  end

  def short_pid
    pid.gsub(/(http|https):\/+(\w+)/, '\2')
  end

  def credit_name
    [given_names, family_name].compact.join(' ')
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
      works.has_events.by_source(source_id).size
    end
  end

  def work_count_by_source=(source_id, time)
    Rails.cache.write("contributor/#{pid}/#{source_id}/work_count/#{time}",
                      works.has_events.by_source(source_id).size)
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
    return if credit_name.present?

    orcid = Array(/^http:\/\/orcid\.org\/(.+)/.match(pid)).last
    return unless orcid.present?

    metadata = get_metadata(orcid, "orcid")
    return if metadata[:error].present?

    author = metadata.fetch('author', [{}]).first

    write_attribute(:orcid, orcid)
    write_attribute(:family_name, author.fetch('family'))
    write_attribute(:given_names, author.fetch('given'))
    write_attribute(:submitted_at, metadata.fetch('timestamp', nil))
  end
end
