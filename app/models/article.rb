class Article < ActiveRecord::Base
  has_many :retrievals, :dependent => :destroy
  has_many :sources, :through => :retrievals
  has_many :citations, :through => :retrievals

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

  named_scope :query, lambda { |query|
    { :conditions => [ "doi like ?", "%#{query}%" ] }
  }

  named_scope :cited, { :include => :retrievals, 
                        :conditions => "retrievals.citations_count > 0 or retrievals.other_citations_count > 0" }

  named_scope :limit, lambda { |limit| (limit > 0) ? {:limit => limit} : {} }

  named_scope :not_refreshed_since, lambda { |last_refresh| 
    { :conditions => ["articles.retrieved_at < ? and articles.published_on <= ?", last_refresh, Date.today ],
      :order => :retrieved_at }
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
            (retrievals.active_sources.any? {|r| r.stale? }))
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
    xml.tag!("article", :doi => doi, :title => title, :citations_count => citations_count,:pub_med => pub_med,:pub_med_central => pub_med_central, :updated_at => retrieved_at, :published => published_on) do
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
        :published => published_on.to_time.to_i,
        :updated_at => retrieved_at.to_i
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

  def self.collect_article_ids(params)
    # Make a list of article IDs given query parameters:
    # cited=0|1
    # query=(doi fragment)
    # order=doi|published_on
    
    where = "where articles.doi like '%#{params[:query].gsub("'","''")}%'" if params[:query]
    order = connection.quote("articles.#{params[:order] || "doi"}")

    if params[:cited]
      # Grab all the articles with 0 recorded citations
      sql = <<SQL
select articles.id, #{order} as sortorder from articles
join retrievals on retrievals.article_id = articles.id
#{where}
group by articles.id
having sum(retrievals.citations_count + retrievals.other_citations_count) #{params[:cited] == "1" ? ">" : "="} 0
SQL
      # if 'uncited', include the articles we haven't retrieved yet, too
      sql += <<SQL if params[:cited] == "0"
union
select articles.id, #{order} as sortorder from articles
left outer join retrievals on articles.id = retrievals.article_id
where retrievals.article_id is null
SQL
    else
      # All articles (possibly limited by the query)
      sql = "select articles.id, #{order} as sortorder from articles #{where}"
    end

    # Always order by DOI
    sql += " order by sortorder"

    Article.connection.select_values(sql)
  end

  def self.load_articles(params, options={})
    # Load articles given query params, for the #index
    article_ids = collect_article_ids(params)
    article_count = article_ids.size
    order = %w{doi published_on}.include?(params[:order]) ? params[:order] : "doi"
    sql = (article_count == 0) \
      ? "select * from articles where 1 = 0" \
      : "select * from articles where id in (#{article_ids.join(",")}) order by #{order}"

    articles = options[:paginate] \
      ? Article.paginate_by_sql(sql, :page => params[:page]) \
      : Article.find_by_sql(sql)
    [articles, article_count]
  end

  def self.load_article(params, options={})
    # Load one article given query params, for the non-#index actions
    doi = DOI::from_uri(params[:id])
    Article.find_by_doi(doi, options) or raise ActiveRecord::RecordNotFound
  end
end
