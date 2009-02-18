class Article < ActiveRecord::Base
  has_many :retrievals, :dependent => :destroy
  has_many :sources, :through => :retrievals
  has_many :citations, :through => :retrievals

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

  named_scope :by, lambda { |order|
    { :order => "#{order}#{(order == :citations_count) ? " desc" : ""}" }
  }
  named_scope :cited, { :include => :retrievals, 
                        :conditions => "retrievals.citations_count > 0 or retrievals.other_citations_count > 0" }

  named_scope :limit, lambda { |limit| (limit > 0) ? {:limit => limit} : {} }

  named_scope :not_refreshed_since, lambda { |last_refresh| 
    { :conditions => ["articles.retrieved_at < ?", last_refresh ] }
  }

  def to_param
    DOI::to_uri(doi)
  end

  def doi=(new_doi)
    write_attribute :doi, DOI::from_uri(new_doi)
  end

  def stale?
    return (new_record? or 
            (retrieved_at < 1.month.ago) or 
            (retrievals.any? {|r| r.stale? }))
  end

  def refreshed!
    self.retrieved_at = Time.zone.now
    self
  end

  def citations_count
    retrievals.inject(0) {|sum, r| sum += r.total_citations_count }
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
    xml.tag!("article", :doi => doi, :citations_count => citations_count,:pub_med => pub_med,:pub_med_central => pub_med_central, :updated_at => retrieved_at) do
      if options[:citations] or options[:history]
        retrieval_options = options.merge!(:dasherize => false, 
                                           :skip_instruct => true)
        retrievals.each do |r| 
          r.to_xml(retrieval_options) \
            if (sources.empty? or sources.include?(r.source.name.downcase)) \
               and (r.total_citations_count > 0)
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
        :pub_med => pub_med,
        :pub_med_central => pub_med_central,
        :citations_count => citations_count,
        :updated_at => retrieved_at
      }
    }
    sources = (options.delete(:source) || '').downcase.split(',')
    if options[:citations] or options[:history]
      result[:article][:sources] = retrievals.map do |r|
        r.to_included_json(options) \
          if (sources.empty? or sources.include?(r.source.name.downcase)) \
             and (r.total_citations_count > 0)
      end.compact
    end
    result.to_json(options)
  end

  def self.a
    # For debugging: this article has existing references
    find_by_doi("10.1371/journal.pbio.0000005")
  end
end
