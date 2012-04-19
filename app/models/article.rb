require "doi"
require "cgi"

class Article < ActiveRecord::Base

  has_many :retrieval_statuses, :dependent => :destroy

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

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
    if order == 'published_on'
      order("published_on")
    else
      order("doi")
    end
  }

  def to_param
    # not necessary to escape the characters make to_param work
    CGI.escape(DOI.to_uri(doi))
  end

  def citations_count
    retrieval_statuses.inject(0) { |sum, r| sum + r.event_count }
  end

  def cited_retrievals_count
    retrieval_statuses.select {|r| r.event_count > 0}.size
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("article",
             :doi => doi,
             :title => title,
             :pub_med => pub_med,
             :pub_med_central => pub_med_central,
             :citations_count => citations_count,
             :published => (published_on.nil? ? nil : published_on.to_time))
  end

  def as_json(options={})
    result = {
        :article => {
            :doi => doi,
            :title => title,
            :pub_med => pub_med,
            :pub_med_central => pub_med_central,
            :citations_count => citations_count,
            :published => (published_on.nil? ? nil : published_on.to_time)
        }
    }

    sources = (options.delete(:source) || '').downcase.split(',')
    if options[:citations] or options[:history]
      result[:article][:source] = retrieval_statuses.map do |rs|
        rs.to_included_json(options) if (sources.empty? or sources.include?(rs.source.name.downcase))
      end.compact
    end
    result
  end

  private
  def create_retrievals
    # Create an empty retrieval record for each active source to avoid a
    # problem with joined tables breaking the UI on the front end
    Source.all.each do |source|
      RetrievalStatus.find_or_create_by_article_id_and_source_id(id, source.id)
    end
  end
end
