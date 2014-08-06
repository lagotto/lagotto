# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cgi'
require 'addressable/uri'
require "builder"

class Article < ActiveRecord::Base
  strip_attributes

  # include HTTP request helpers
  include Networkable

  # include helper module for DOI resolution
  include Resolvable

  belongs_to :publisher
  has_many :retrieval_statuses, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses

  validates :uid, :title, :year, :presence => true
  validates :doi, :uniqueness => true , :format => { :with => DOI_FORMAT }, :allow_nil => true
  validates :year, :numericality => { :only_integer => true }, :inclusion => { :in => 1650..(Time.zone.now.year), :message => "should be between 1650 and #{Time.zone.now.year}" }
  validate :validate_published_on

  before_validation :sanitize_title
  after_create :create_retrievals

  scope :query, lambda { |query| where("doi like ?", "#{query}%") }

  scope :last_x_days, lambda { |duration| where(published_on: (Date.today - duration.days)..Date.today) }
  scope :is_cited, lambda { includes(:retrieval_statuses).where("retrieval_statuses.event_count > ?", 0) }

  def self.from_uri(id)
    return nil if id.nil?

    id = id.gsub("%2F", "/")

    case
    when id.starts_with?("http://dx.doi.org/") then { doi: id[18..-1] }
    when id.starts_with?("info:doi/")          then { doi: CGI.unescape(id[9..-1]) }
    when id.starts_with?("info:pmid/")         then { pmid: id[10..-1] }
    when id.starts_with?("info:pmcid/PMC")     then { pmcid: id[14..-1] }
    when id.starts_with?("info:pmcid/")        then { pmcid: id[11..-1] }
    when id.starts_with?("info:mendeley/")     then { mendeley_uuid: id[14..-1] }
    else { uid.to_sym => id }
    end
  end

  def self.to_uri(id, escaped=true)
    return nil if id.nil?
    unless id.starts_with? "info:"
      id = "info:#{uid}/" + from_uri(id).values.first
    end
    id
  end

  def self.to_url(doi)
    return nil if doi.nil?
    return doi if doi.starts_with? "http://dx.doi.org/"
    "http://dx.doi.org/#{from_uri(doi).values.first}"
  end

  def self.clean_id(id)
    if id.starts_with? "10."
      Addressable::URI.unencode(id)
    elsif id.starts_with? "PMC"
      id[3..-1]
    else
      id
    end
  end

  def self.uid
    # use the column name defined in settings.yml, default to doi
    CONFIG[:uid] || "doi"
  end

  def self.uid_as_sym
    uid.to_sym
  end

  def self.validate_format(id)
    case CONFIG[:uid]
    when "doi"
      id =~ DOI_FORMAT
    else
      true
    end
  end

  def self.find_or_create(params)
    self.create!(params)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    # update title and/or date if article exists
    # this is faster than find_or_create_by_doi for all articles
    # raise an error for other RecordInvalid errors such as missing title
    if e.message.start_with?("Mysql2::Error: Duplicate entry", "Validation failed: Doi has already been taken")
      article = find_by_doi(params[:doi])
      article.update_attributes(params)
      article
    else
      Alert.create(:exception => "",
                   :class_name => "ActiveRecord::RecordInvalid",
                   :message => "#{e.message} for doi #{params[:doi]}.",
                   :target_url => "http://api.crossref.org/works/#{params[:doi]}")
      nil
    end
  end

  def uid
    send(self.class.uid)
  end

  def uid_escaped
    CGI.escape(uid)
  end

  def to_param
    self.class.to_uri(uid)
  end

  def self.per_page
    50
  end

  def events_count
    retrieval_statuses.reduce(0) { |sum, r| sum + r.event_count }
  end

  def cited_retrievals_count
    retrieval_statuses.select { |r| r.event_count > 0 }.size
  end

  # Filter retrieval_statuses by source
  def retrieval_statuses_by_source(options={})
    if options[:source]
      source_ids = Source.where("lower(name) in (?)", options[:source].split(",")).order("name").pluck(:id)
      retrieval_statuses.by_source(source_ids)
    else
      retrieval_statuses
    end
  end

  def doi_escaped
    if doi
      CGI.escape(doi)
    else
      nil
    end
  end

  def doi_as_url
    if doi =~ DOI_FORMAT
      Addressable::URI.encode("http://dx.doi.org/#{doi}")
    else
      nil
    end
  end

  def get_url
    return true if canonical_url.present?
    return false unless doi.present?

    url = get_canonical_url(doi_as_url)

    if url.present? && url.is_a?(String)
      update_attributes(:canonical_url => url)
    else
      false
    end
  end

  # call Pubmed API to get missing identifiers
  # update article if we find a new identifier
  def get_ids
    ids = { doi: doi, pmid: pmid, pmcid: pmcid }
    missing_ids = ids.reject { |k, v| v.present? }
    return true if missing_ids.empty?

    result = get_persistent_identifiers(uid)
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

  def is_publisher?
    doi =~ /^#{CONFIG[:doi_prefix].to_s}/
  end

  def signposts
    sources.pluck_all(:name, :event_count, :events_url)
  end

  def event_count(name)
    signposts.reduce(0) do |sum, hash|
      hash["name"] == name ? hash['event_count'].to_i : sum
    end
  end

  def events_url(name)
    signposts.reduce(nil) { |sum, hash| hash["name"] == name ? hash['events_url'] : sum }
  end

  def mendeley_url
    events_url("mendeley")
  end

  def citeulike_url
    events_url("citeulike")
  end

  def views
    event_count("pmc") + event_count("counter")
  end

  def shares
    event_count("facebook") + event_count("twitter") + event_count("twitter_search")
  end

  def bookmarks
    event_count("citeulike") + event_count("mendeley")
  end

  def citations
    if CONFIG[:doi_prefix] == "10.1371"
      event_count("scopus")
    else
      event_count("crossref")
    end
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
  # Uses nil if invalid date
  def update_published_on
    date_parts = [year, month, day].reject(&:blank?)
    published_on = Date.new(*date_parts)
    if published_on > Date.today
      errors.add :published_on, "is a date in the future"
    else
      write_attribute(:published_on, published_on)
    end
  rescue ArgumentError
    nil
  end

  def validate_published_on
    errors.add :published_on, "is not a valid date" unless update_published_on
  end

  def sanitize_title
    self.title = ActionController::Base.helpers.sanitize(title)
  end

  def create_retrievals
    # Create an empty retrieval record for every installed source for the new article

    # Schedule retrieval immediately, rate-limiting will automatically limit the external API calls
    # when we bulk-upload lots of articles.

    Source.installed.each do |source|
      RetrievalStatus.find_or_create_by_article_id_and_source_id(id, source.id, :scheduled_at => Time.zone.now)
    end
  end
end
