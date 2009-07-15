class Retrieval < ActiveRecord::Base
  belongs_to :source
  belongs_to :article
  has_many :citations, :dependent => :destroy
  has_many :histories, :dependent => :destroy

  named_scope :most_cited_sample, :limit => 5,
    :order => "(citations_count + other_citations_count) desc"

  def total_citations_count
    citations_count + other_citations_count
  end

  def stale?
    new_record? or retrieved_at.nil? or (retrieved_at < source.staleness.ago)
  end

  def to_included_json(options = {})
    result = {
      :source => source.name,
      :updated_at => retrieved_at.to_i,
      :count => total_citations_count
    }
    result[:citations] = citations.map(&:to_included_json) \
      if options[:citations] == "1" and not citations.empty?
    result[:histories] = histories.map(&:to_included_json) \
      if options[:history] == "1" and not histories.empty?
    public_url = source.public_url(self)
    result[:public_url] = public_url \
      if public_url
    result[:search_url] = source.searchURL if source.uses_search_url
    result
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    attributes = {
      :source => source.name, 
      :updated_at => retrieved_at,
      :count => total_citations_count 
    }
    public_url = source.public_url(self)
    attributes[:public_url] = public_url if public_url
    attributes[:search_url] = source.searchURL if source.uses_search_url
        
    xml.tag!("source", attributes) do
      nested_options = options.merge!(:dasherize => false,
                                      :skip_instruct => true)
      if options[:citations] == "1" and not citations.empty?
        xml.tag!("citations") { citations.each {|c| c.to_xml(nested_options) } }
      end
      if options[:history] == "1" and not histories.empty?
        xml.tag!("histories") { histories.each {|h| h.to_xml(nested_options) } }
      end
    end
  end
end
