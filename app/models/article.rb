# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
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

class Article < ActiveRecord::Base
  
  has_many :retrievals, :dependent => :destroy
  has_many :sources, :through => :retrievals
  has_many :citations, :through => :retrievals

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

  named_scope :query, lambda { |query|
    { :conditions => [ "doi like ?", "%#{query}%" ] }
  }
  
  named_scope :cited, lambda { |cited|
    case cited
    when '1', 1
      { :include => :retrievals,
        :conditions => "retrievals.citations_count > 0 OR retrievals.other_citations_count > 0" }
    when '0', 0
      { :conditions => 'articles.id IN (SELECT articles.id FROM articles LEFT OUTER JOIN retrievals ON retrievals.article_id = articles.id GROUP BY articles.id HAVING IFNULL(SUM(retrievals.citations_count) + SUM(retrievals.other_citations_count), 0) = 0)' }
    else
      {}
    end
  }

  named_scope :limit, lambda { |limit| (limit && limit > 0) ? {:limit => limit} : {} }

  named_scope :order, lambda { |order|
    if order == 'published_on'
      { :order => 'published_on' }
    else
      {}
    end
  }

  named_scope :stale_and_published,
    :conditions => ["(exists(select retrievals.id from retrievals join sources on retrievals.source_id = sources.id where retrievals.article_id = articles.id and retrievals.retrieved_at < TIMESTAMPADD(SECOND, -sources.staleness, UTC_TIMESTAMP()) and sources.active = 1 and (sources.disable_until is null or sources.disable_until < UTC_TIMESTAMP())) or not exists(select id from retrievals where retrievals.article_id = articles.id and retrieved_at is not null)) and articles.published_on <= ?", Time.zone.today],
    :order => :retrieved_at

  default_scope :order => 'articles.doi'

  def to_param
    DOI.to_uri(doi)
  end

  def doi=(new_doi)
    self[:doi] = DOI.from_uri(new_doi)
  end

  def stale?
    new_record? or retrievals.empty? or retrievals.active_sources.any?(&:stale?)
  end

  def refreshed!
    self.retrieved_at = Time.zone.now
    self
  end
  
  #Get citation count by group and sources from the activerecord data
  def citations_by_group
    results = {}
    
    for ret in retrievals
      if results[ret.source.group_id] == nil then
        results[ret.source.group_id] = {
          :name => ret.source.group.name.downcase,
          :total => ret.citations_count + ret.other_citations_count,
          :sources => []
        }
        results[ret.source.group_id][:sources] << {
          :name => ret.source.name,
          :total => ret.citations_count + ret.other_citations_count,
          :public_url => ret.source.public_url
        }
      else
        results[ret.source.group_id][:total] = results[ret.source.group_id][:total] + ret.citations_count + ret.other_citations_count
        results[ret.source.group_id][:sources] << {
          :name => ret.source.name,
          :total => ret.citations_count + ret.other_citations_count,
          :public_url => ret.source.public_url
        }
      end
    end
    
    groupsCount = []
    
    results.each do | key, value |
      groupsCount << value
    end
    
    groupsCount
  end
  
  #Get cites for the given source from the activeRecord data
  def get_cites_by_group(groupname)
    groupname = groupname.downcase
    retrievals.map do |ret|
      if ret.source.group.name.downcase == groupname && (ret.citations_count + ret.other_citations_count) > 0
        #Cast this to an array to get around a ruby 'singularize' bug
        { :name => ret.source.name.downcase, :citations => ret.citations.to_a }
      end
    end.compact
  end
  
  def citations_count
    retrievals.inject(0) {|sum, r| sum + r.total_citations_count }
    # retrievals.sum(:citations_count) + retrievals.sum(:other_citations_count)
  end

  def cited_retrievals_count
    retrievals.select {|r| r.total_citations_count > 0 }.size
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    sources = (options.delete(:source) || '').downcase.split(',')
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("article", :doi => doi, :title => title, :citations_count => citations_count,:pub_med => pub_med,:pub_med_central => pub_med_central, :updated_at => retrieved_at, :published => published_on.to_time) do
      if options[:citations] or options[:history]
        retrieval_options = options.merge!(:dasherize => false, 
                                           :skip_instruct => true)
        retrievals.each do |r| 
          r.to_xml(retrieval_options) \
            if (sources.empty? or sources.include?(r.source.name.downcase)) 
               #If the result set is emtpy, lets not return any information about the source at all
               #\
               #and (r.total_citations_count > 0)
        end
      end
    end
  end

  def explain
    msgs = ["[#{id}]: #{doi} #{retrieved_at}#{" stale" if stale?}"]
    retrievals.each {|r| msgs << "  [#{r.id}] #{r.source.name} #{r.retrieved_at}#{" stale" if r.stale?}"}
    msgs.join("\n")
  end

  def to_json(options={})
    result = { 
      :article => { 
        :doi => doi, 
        :title => title, 
        :pub_med => pub_med,
        :pub_med_central => pub_med_central,
        :citations_count => citations_count,
        :published => published_on.to_time,
        :updated_at => retrieved_at
      }
    }
    sources = (options.delete(:source) || '').downcase.split(',')
    if options[:citations] or options[:history]
      result[:article][:source] = retrievals.map do |r|
        r.to_included_json(options) \
          if (sources.empty? or sources.include?(r.source.name.downcase)) 
             #If the result set is emtpy, lets not return any information about the source at all
             #\
             #and (r.total_citations_count > 0)
      end.compact
    end
    result.to_json(options)
  end
end
