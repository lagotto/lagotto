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
  
  default_scope order("retrieved_at")
  
  scope :after_days, lambda { |days| joins(:article).where("retrieved_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days) }
  scope :after_months, lambda { |months| joins(:article).where("retrieved_at BETWEEN CURDATE() - INTERVAL ? MONTH AND CURDATE()", months) }
  scope :until_year, lambda { |year| joins(:article).where("YEAR(retrieved_at) <= ?", year) }
  
  scope :total, lambda { |days| where("retrieved_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days) }
  scope :with_success, lambda { |days| where("status = 'SUCCESS' AND retrieved_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days) }
  scope :with_no_data, lambda { |days| where("status = 'SUCCESS WITH NO DATA' AND retrieved_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days) }
  scope :with_errors, lambda { |days| where("status = 'ERROR' AND retrieved_at BETWEEN CURDATE() - INTERVAL ? DAY AND CURDATE()", days) }

  def data
    begin
      data = get_alm_data(id)
    rescue => e
      logger.error "Failed to get data for #{id}. #{e.message}"
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
    nil
  end
  
  def html
    nil
  end
  
  def shares
    case source.name
    when "citeulike"
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
    if ["crossref","pubmed","researchblogging","nature","scienceseeker"].include?(source.name)
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
