class Source < ActiveRecord::Base
  has_many :retrievals, :dependent => :destroy

  validates_presence_of :url, :if => :uses_url
  validates_presence_of :username, :if => :uses_username
  validates_presence_of :password, :if => :uses_password
  validates_presence_of :salt, :if => :uses_salt

  validates_numericality_of :staleness_days,
    :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 366

  attr_accessor :staleness_days_before_type_cast

  named_scope :active, { :conditions => {:active => true} }

  def self.unconfigured_source_names
    # Collect source classnames based on the source file names we have
    @@subclass_names ||= Dir["#{RAILS_ROOT}/app/models/sources/*.rb"].map do |file| 
      File.basename(file, ".rb").camelize
    end
    # Ignore any that are already configured
    @@subclass_names.reject { |k| all.any? { |c| c.class.name == k } }
  end

  def name
    read_attribute(:name) || self.class.name
  end

  def inspect_with_password_filtering
    result = inspect_without_password_filtering
    result.gsub!(", password: \"#{password}\"", '') if password
    result
  end
  alias_method_chain :inspect, :password_filtering

  def staleness
    SecondsToDuration::convert(read_attribute(:staleness))
  end

  def staleness_days
    read_attribute(:staleness) / 1.day
  end

  def staleness_days=(days)
    @staleness_days_before_type_cast = days
    write_attribute(:staleness, days.to_i.days)
  end

  def staleness_days_before_type_cast
    @staleness_days_before_type_cast || staleness_days
  end

  def self.maximum_staleness
    SecondsToDuration::convert(Source.maximum(:staleness))
  end

  def public_url(retrieval)
    # When generating a public URL to an article's citations on the source
    # site, we'll add the encoded DOI to a base URL provided by the source
    # (or nil if none's provided)
    base = public_url_base
    base && base + CGI.escape(retrieval.article.doi)
  end
  def public_url_base
    nil
  end

  # Subclasses should override these to cause fields to appear in UI, and
  # enable their validations
  def uses_url; false; end
  def uses_username; false; end
  def uses_password; false; end
  def uses_live_mode; false; end
  def uses_salt; false; end
end
