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
  
  default_scope order("retrieved_at")
  
  scope :after_days, lambda { |days| joins(:article).where("retrieved_at <= articles.published_on + INTERVAL ? DAY", days) }
  scope :after_months, lambda { |months| joins(:article).where("retrieved_at <= articles.published_on + INTERVAL ? MONTH", months) }
  scope :until_year, lambda { |year| joins(:article).where("YEAR(retrieved_at) <= ?", year) }
  
  scope :total, lambda { |days| where("retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :with_success, lambda { |days| where("event_count > 0 AND retrieved_at > NOW() - INTERVAL ? DAY", days) }
  scope :with_errors, lambda { |days| where("status = 'ERROR' AND retrieved_at > NOW() - INTERVAL ? DAY", days) }

  def self.table_status
    table_status = ActiveRecord::Base.connection.select_all("SHOW TABLE STATUS LIKE 'retrieval_histories'").first
    Hash[table_status.map {|k, v| [k.to_s.underscore, v] }]
  end
  
  def data
    if event_count > 0
      data = get_alm_data(id)
      nil if data.blank? or data["error"]
    else
      nil
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
  
  def metrics    
    case retrieval_status.source.name
    when "citeulike"
      { :pdf => nil, :html => nil, :shares => event_count, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "facebook"
      { :pdf => nil, :html => nil, :shares => events.inject(0) { |sum, hash| sum + hash["share_count"] }, :groups => nil, :comments => events.inject(0) { |sum, hash| sum + hash["comment_count"] }, :likes => events.inject(0) { |sum, hash| sum + hash["like_count"] }, :citations => nil, :total => event_count }
    when "mendeley"
      { :pdf => nil, :html => nil, :shares => (events.blank? ? 0 : events['stats']['readers']), :groups => (events.blank? ? 0 : events['groups'].length), :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "wikipedia"
      { :pdf => nil, :html => nil, :shares => events.select {|event| event["namespace"] > 0 }.length, :groups => nil, :comments => nil, :likes => nil, :citations => events.select {|event| event["namespace"] == 0 }.length, :total => event_count }
    else
    # crossref, pubmed, researchblogging, nature, scienceseeker 
      { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => event_count, :total => event_count }
    end
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
