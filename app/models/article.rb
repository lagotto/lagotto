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

  # Format used for DOI validation - we want to store DOIs without
  # the leading "info:doi/"
  FORMAT = %r(^\d+\.[^/]+/[^/]+)

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :retrieval_histories, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses

  validates :uid, :title, :year, :presence => true
  validates :doi, :uniqueness => true , :format => { :with => FORMAT }, :allow_nil => true
  validates :year, :numericality => { :only_integer => true }, :inclusion => { :in => 1660..(Time.zone.now.year + 1), :message => "should be between 1660 and #{Time.zone.now.year + 1}" }
  validate :validate_published_on

  before_validation :sanitize_title
  after_create :create_retrievals

  scope :query, lambda { |query|
    if self.has_many?
      where("doi like ?", "#{query}%")
    else
      where("doi like ? OR title like ?", "%#{query}%", "%#{query}%")
    end
  }

  scope :last_x_days, lambda { |duration| where(published_on: (Date.today-duration.days)..Date.today) }
  scope :is_cited, lambda { includes(:retrieval_statuses).where("retrieval_statuses.event_count > ?", 0) }

  scope :order_articles, lambda { |name|
    if name.blank?
      order("published_on DESC")
    else
      where("retrieval_statuses.event_count > 0").order("retrieval_statuses.event_count DESC, published_on DESC")
    end
  }

  # simplify admin dashboard when we have more than 150,000 articles
  def self.has_many?
    Article.count > 150000
  end

  def self.from_uri(id)
    return nil if id.nil?
    id = id.gsub("%2F", "/")
    if id.starts_with? "http://dx.doi.org/"
      { :doi => id[18..-1] }
    elsif id.starts_with? "info:doi/"
      { :doi => CGI.unescape(id[9..-1]) }
    elsif id.starts_with? "info:pmid/"
      { :pmid => id[10..-1] }
    elsif id.starts_with? "info:pmcid/"
      # Strip PMC prefix
      id = id[3..-1] if id[11..13] == "PMC"
      { :pmcid => id[11..-1] }
    elsif id.starts_with? "info:mendeley/"
      { :mendeley_uuid => id[14..-1] }
    else
      { self.uid.to_sym => id }
    end
  end

  def self.to_uri(id, escaped=true)
    return nil if id.nil?
    unless id.starts_with? "info:"
      id = "info:#{self.uid}/" + from_uri(id).values.first
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

  def uid
    self.send(Article.uid)
  end

  def uid_escaped
    CGI.escape(uid)
  end

  def to_param
    Article.to_uri(uid)
  end

  def self.per_page
    50
  end

  def events_count
    retrieval_statuses.inject(0) { |sum, r| sum + r.event_count }
  end

  def cited_retrievals_count
    retrieval_statuses.select {|r| r.event_count > 0}.size
  end

  # Filter retrieval_statuses by source
  def retrieval_statuses_by_source(options={})
    if options[:source]
      source_ids = Source.where("lower(name) in (?)", options[:source].split(",")).order("name").pluck(:id)
      self.retrieval_statuses.by_source(source_ids)
    else
      self.retrieval_statuses
    end
  end

  def doi_escaped
    CGI.escape(doi)
  end

  def doi_as_url
    if doi[0..2] == "10."
      Addressable::URI.encode("http://dx.doi.org/#{doi}")
    else
      nil
    end
  end

  def get_url
    return true if canonical_url.present?
    return false unless doi.present?

    url = get_canonical_url(doi_as_url)

    if url.present?
      update_attributes(:canonical_url => url)
    else
      false
    end
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
    CONFIG[:doi_prefix].to_s == doi[0..6]
  end

  def pmc
    retrieval_statuses.by_name("pmc").first
  end

  def counter
    retrieval_statuses.by_name("counter").first
  end

  def mendeley
    retrieval_statuses.by_name("mendeley").first
  end

  def citeulike
    retrieval_statuses.by_name("citeulike").first
  end

  def facebook
    retrieval_statuses.by_name("facebook").first
  end

  def twitter
    retrieval_statuses.by_name("twitter").first
  end

  def scopus
    retrieval_statuses.by_name("scopus").first
  end

  def views
    (pmc.nil? ? 0 : pmc.event_count) + (counter.nil? ? 0 : counter.event_count)
  end

  def shares
    (facebook.nil? ? 0 : facebook.event_count) + (twitter.nil? ? 0 : twitter.event_count)
  end

  def bookmarks
    (citeulike.nil? ? 0 : citeulike.event_count) + (mendeley.nil? ? 0 : mendeley.event_count)
  end

  def citations
    (scopus.nil? ? 0 : scopus.event_count)
  end

  alias_method :viewed, :views
  alias_method :saved, :bookmarks
  alias_method :discussed, :shares
  alias_method :cited, :citations

  def update_date_parts
    return nil unless published_on

    write_attribute(:year, published_on.year)
    write_attribute(:month, published_on.month)
    write_attribute(:day, published_on.day)
  end

  private

  # Use values from year, month, day for published_on
  # Uses  "01" for month and day if they are missing
  # Uses nil if invalid date
  def update_published_on
    date_parts = [year, month, day].reject(&:blank?)
    published_on = Date.new(*date_parts) rescue nil
    write_attribute(:published_on, published_on)
  end

  def validate_published_on
    errors.add :published_on, "is not a valid date" unless update_published_on
  end

  def sanitize_title
    self.title = ActionController::Base.helpers.sanitize(self.title)
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
