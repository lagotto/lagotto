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

class Source < ActiveRecord::Base
  has_many :retrievals, :dependent => :destroy
  belongs_to :group
  
  validates_presence_of :name
  validates_presence_of :url, :if => :uses_url
  validates_presence_of :username, :if => :uses_username
  validates_presence_of :password, :if => :uses_password
  validates_presence_of :salt, :if => :uses_salt
  validates_presence_of :partner_id, :if => :uses_partner_id

  validates_numericality_of :staleness_days,
    :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 366

  after_create :create_retrievals

  attr_accessor :staleness_days_before_type_cast

  named_scope :active, :conditions => {:active => true}

  def self.unconfigured_source_names
    # Collect source classnames based on the source file names we have
    @@subclass_names ||= Dir[Rails.root + "app/models/sources/*.rb"].map do |file|
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
  
  #This method generates the CSV values of the values passed in.  
  #Each source may store the citation details in a slightly
  #different manner.  If a particular source has details that are highly 
  #structured, override this method to simplify things a bit
  def citations_to_csv(csv, retrieval)
      if retrieval.citations.first
        csv << retrieval.citations.first.details.keys
    
        retrieval.citations.each do |citation|
          if(citation.details != nil)
            csv << citation.details.map {| k, v| v }
          end
        end
      end
  end

  def perform_query
    raise NotImplementedError, 'Children classes should override perform_query'
  end

  def query article, options = {}
    if disable_until and disable_until > Time.zone.now
      Rails.logger.info "#{name} is disabled until #{disable_until}. Skipping."
      return false
    end

    returning perform_query(article, options) do
      self.disable_until = nil
      self.disable_delay = Source.new.disable_delay
    end
  rescue RetrieverTimeout => e
    Rails.logger.info "Forced Timeout on query.  Not disabling this source."
    raise e
  rescue Exception => e
    Rails.logger.info "#{name} had an error. Disabling for #{SecondsToDuration::convert(disable_delay).inspect}."
    Notifier.deliver_long_delay_warning(self)  if disable_delay > 1.day
    self.disable_until = Time.zone.now + disable_delay.seconds
    self.disable_delay *= 2
    raise e
  ensure
    save!
  end

  def self.maximum_staleness
    SecondsToDuration::convert(Source.maximum(:staleness))
  end
  
  def self.minimum_staleness
    SecondsToDuration::convert(Source.minimum(:staleness))
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
  def uses_search_url; false end
  def uses_username; false; end
  def uses_password; false; end
  def uses_live_mode; false; end
  def uses_salt; false; end
  def uses_partner_id; false; end

  private
    def create_retrievals
      # Create an empty retrieval record for each active source to avoid a
      # problem with joined tables breaking the UI on the front end

      # there are two ways to create a retrieval row.
      # 1. logic below
      # 2. When an article gets updated, a retrieval row is either created or updated via
      #    Retrieval.find_or_create_by_article_id_and_source_id(article.id, source.id) method
      # to keep the two logic consistent, created_at date has been added here

      Retrieval.connection.execute "
        INSERT INTO retrievals (article_id, source_id, created_at)
          SELECT id, #{id}, now() FROM articles
          WHERE id NOT IN
            (SELECT article_id FROM retrievals WHERE source_id = #{id})"
    end
end
