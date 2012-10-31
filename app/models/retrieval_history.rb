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

require 'source_helper'

class RetrievalHistory < ActiveRecord::Base
  include SourceHelper

  belongs_to :retrieval_status
  belongs_to :article
  belongs_to :source

  SUCCESS_MSG = "SUCCESS"
  SUCCESS_NODATA_MSG = "SUCCESS WITH NO DATA"
  ERROR_MSG = "ERROR"
  SKIPPED_MSG = "SKIPPED"
  SOURCE_DISABLED = "Source disabled"
  SOURCE_NOT_ACTIVE = "Source not active"
  
  scope :after_days, lambda { |days| joins(:article).where("DATE(retrieved_at) <= TIMESTAMPADD(DAY,?,articles.published_on)", days).order("retrieved_at") }
  scope :after_months, lambda { |months| joins(:article).where("DATE(retrieved_at) <= TIMESTAMPADD(MONTH,?,articles.published_on)", months).order("retrieved_at") }

  def data
    begin
      data = get_alm_data(id)
    rescue => e
      Rails.logger.error "Failed to get data for #{id}. #{e.message}"
      data = nil
    end
  end
  
  def public_url
    data["events_url"] unless data.nil?
  end
  
  def events
    unless data.nil?
      data["events"]
    else
      []
    end
  end
  
  def pdf
    case source.name
    when "counter"
      events.inject(0) { |sum, hash| sum + hash["pdf_views"].to_i }
    when "pmc"
      events.inject(0) { |sum, hash| sum + hash["pdf"].to_i }
    when "biod"
      events.inject(0) { |sum, hash| sum + hash["pdf_views"].to_i }
    else
      nil
    end
  end
  
  def html
    case source.name
    when "counter"
      events.inject(0) { |sum, hash| sum + hash["html_views"].to_i }
    when "pmc"
      events.inject(0) { |sum, hash| sum + hash["full-text"].to_i }
    when "biod"
      events.inject(0) { |sum, hash| sum + hash["html_views"].to_i }
    else
      nil
    end
  end
  
  def xml
    case source.name
    when "counter"
      events.inject(0) { |sum, hash| sum + hash["xml_views"].to_i }
    when "biod"
      events.inject(0) { |sum, hash| sum + hash["xml_views"].to_i }
    else
      nil
    end
  end
  
  def shares
    case source.name
    when "citeulike"
      event_count
    when "connotea"
      event_count
    when "postgenomic"
      event_count
    when "mendeley"
      if events.blank? or events['stats'].nil? 
        0
      else
        events['stats']['readers']
      end
    when "wikipedia"
      events.select {|event| event["namespace"] > 0 }.length
    when "facebook"
      events.inject(0) { |sum, hash| sum + hash["share_count"] }
    else
      nil
    end
  end
  
  def groups
    if source.name == "mendeley"
      if events.blank? or events['groups'].nil?
        0
      else
        events['groups'].length
      end
    else
      nil
    end
  end
 
  def comments
    case source.name
    when "facebook"
      events.inject(0) { |sum, hash| sum + hash["comment_count"] }
    when "twitter"
      event_count
    else
      nil
    end
  end
  
  def likes
    case source.name
    when "facebook"
      events.inject(0) { |sum, hash| sum + hash["like_count"] }
    else
      nil
    end
  end
  
  def citations
    if ["crossref","pubmed","researchblogging","nature","wos","scopus","bloglines"].include?(source.name)
      event_count
    elsif source.name == "wikipedia"
      events.select {|event| event["namespace"] == 0 }.length
    else
      nil
    end
  end
  
  def total
    if source.name == "mendeley" and v1_format?
      shares + groups
    elsif source.name == "facebook" and v1_format?
      events.inject(0) { |sum, hash| sum + hash["total_count"] }
    elsif source.name == "counter" and v1_format?
      pdf + xml + html
    elsif source.name == "pmc" and v1_format?
      pdf + html
    else
      event_count
    end
  end
  
  def metrics
    { :pdf => pdf, :html => html, :shares => shares, :groups => groups, :comments => comments, :likes => likes, :citations => citations, :total => total }
  end
  
  def v1_format?
    updated_at < Date.parse("2012-07-31")
  end
  
  def as_json
    {
        :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time),
        :count => event_count
    }
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("history", :updated_at => (retrieved_at.nil? ? nil: retrieved_at.to_time), :count => event_count)
  end

end
