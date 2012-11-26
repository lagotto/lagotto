# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
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

require "cgi"
require "builder"

class Article < ActiveRecord::Base
  
  # Format used for DOI validation - we want to store DOIs without
  # the leading "info:doi/"
  FORMAT = %r(^\d+\.[^/]+/[^/]+)

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :retrieval_histories, :dependent => :destroy
  has_many :sources, :through => :retrieval_statuses
  
  validates :uid, :title, :presence => true
  validates :doi, :uniqueness => true , :format => { :with => FORMAT }, :allow_blank => true
  validates :published_on, :presence => true, :timeliness => { :on_or_before => lambda { 3.months.since }, :on_or_before_message => "can't be more than thee months in the future", 
                                                               :after => lambda { 50.years.ago }, :after_message => "must not be older than 50 years", 
                                                               :type => :date }
  
  after_create :create_retrievals

  scope :query, lambda { |query| where("doi like ?", "%#{query}%") }

  scope :cited, lambda { |cited|
    case cited
      when '1', 1
        includes(:retrieval_statuses).where("retrieval_statuses.event_count > 0")
      when '0', 0
        where('EXISTS (SELECT * from retrieval_statuses where article_id = `articles`.id GROUP BY article_id HAVING SUM(IFNULL(retrieval_statuses.event_count,0)) = 0)')
    end
  }

  scope :order_articles, lambda { |order|
    if order == 'doi'
      order("doi")
    else
      order("published_on DESC")
    end
  }
  
  def self.from_uri(id)
    return nil if id.nil?
    id = id.gsub("%2F", "/")
    if id.starts_with? "http://dx.doi.org/"
      { :doi => id[18..-1] }
    elsif id.starts_with? "info:doi/"
      { :doi => id[9..-1] }
    elsif id.starts_with? "info:pmid/"
      { :pub_med => id[10..-1] }
    elsif id.starts_with? "info:pmcid/"
      # Strip PMC prefix
      id = id[3..-1] if id[11..13] == "PMC"
      { :pub_med_central => id[11..-1] }
    elsif id.starts_with? "info:mendeley/"
      { :mendeley => id[14..-1] }
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

  def self.to_url(id)
    return nil if id.nil?
    unless id.starts_with? "http://dx.doi.org/"
      id = "http://dx.doi.org/" + from_uri(id).values.first
    end
    id
  end
  
  def self.clean_id(id)
    if id.starts_with? "10."
      URI.unescape(id)
    elsif id.starts_with? "PMC"
      id[3..-1]
    else
      id
    end
  end
  
  def self.uid
    # use the column name defined in settings.yml, default to doi
    APP_CONFIG["uid"] || "doi"
  end
    
  def uid
    self.send(Article.uid)
  end

  def to_param
    CGI.escape(Article.to_uri(uid))
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
  
  def doi_as_url
    if doi[0..2] == "10."
      "http://dx.doi.org/" + doi
    else
      nil
    end
  end
  
  def doi_as_publisher_url
    # for now use the PLOS doi resolver
    if doi[0..6] == "10.1371"
      "http://dx.plos.org/" + doi
    else
      nil
    end
  end

  def to_xml(options = {})
    sources = (options.delete(:source) || '').downcase.split(',')

    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("article",
             :doi => doi,
             :title => title,
             :pub_med => pub_med,
             :pub_med_central => pub_med_central,
             :events_count => events_count,
             :published => (published_on.nil? ? nil : published_on.to_time)) do

      if options[:events] or options[:history]
        retrieval_options = options.merge!(:dasherize => false,
                                           :skip_instruct => true)

        retrieval_statuses.each do |rs|
          rs.to_xml(retrieval_options) if (sources.empty? or sources.include?(rs.source.name.downcase))
        end
      end
    end
  end

  def as_json(options={})
    result = {
        :article => {
            :doi => doi,
            :title => title,
            :pub_med => pub_med,
            :pub_med_central => pub_med_central,
            :events_count => events_count,
            :published => (published_on.nil? ? nil : published_on.to_time)
        }
    }

    sources = (options.delete(:source) || '').downcase.split(',')
    if options[:events] or options[:history]
      result[:article][:source] = retrieval_statuses.map do |rs|
        rs.as_json(options) if (sources.empty? or sources.include?(rs.source.name.downcase))
      end.compact
    end
    result
  end

  def get_data_by_group(group)
    data = []
    r_statuses = retrieval_statuses.joins(:source => :group).where("groups.id = ?", group.id)
    r_statuses.each do |rs|
      if rs.event_count > 0
        if not rs.data.nil?
          data << {:source => rs.source.display_name,
                   :events => rs.data["events"]}
        end
      end
    end
    data
  end

  def group_source_info
    group_info = {}
    retrieval_statuses.each do |rs|
      if not rs.source.group.nil? and rs.event_count > 0
        group_id = rs.source.group.id
        group_info[group_id] = [] if group_info[group_id].nil?
        group_info[group_id] << {:source => rs.source.display_name,
                                 :count => rs.event_count,
                                 :public_url => rs.public_url}
      end
    end
    group_info
  end
  
  def is_publisher?
    APP_CONFIG["doi_prefix"].to_s == doi[0..6]
  end

  private
  def create_retrievals
    # Create an empty retrieval record for every source for the new article
    Source.all.each do |source|
      RetrievalStatus.find_or_create_by_article_id_and_source_id(id, source.id, :scheduled_at => Time.zone.now)
    end
  end
end
