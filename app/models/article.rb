require "doi"
require "cgi"
require "builder"

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

  def events_count
    retrieval_statuses.inject(0) { |sum, r| sum + r.event_count }
  end

  def cited_retrievals_count
    retrieval_statuses.select {|r| r.event_count > 0}.size
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

  def update_data_from_sources
    # get a list of sources that we can get data from right now
    # counter data can only be queried at very specific time frame only so it will be excluded
    # nature has api limit so it will get updated if it can be updated.

    sources = Source.data_retrievable_sources
    sources.each do |source|
      rs = RetrievalStatus.where(:article_id => id, :source_id => source.id).first
      if not rs.nil?
        source.queue_article_job(rs, Source::TOP_PRIORITY)
      end
    end

  end

  def get_data_by_group(group)
    data = []
    r_statuses = retrieval_statuses.joins(:source => :group).where("groups.id = ?", group.id)
    r_statuses.each do |rs|
      if rs.event_count > 0
        events_data = rs.get_retrieval_data
        if not events_data.nil?
          data << {:source => rs.source.display_name,
                   :events => events_data["events"]}
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

  private
  def create_retrievals
    # Create an empty retrieval record for every source for the new article
    Source.all.each do |source|
      RetrievalStatus.find_or_create_by_article_id_and_source_id(id, source.id)
    end
  end
end
