class Article < ActiveRecord::Base
  include Log
  
  has_many :retrievals, :dependent => :destroy
  has_many :sources, :through => :retrievals
  has_many :citations, :through => :retrievals

  validates_format_of :doi, :with => DOI::FORMAT
  validates_uniqueness_of :doi

  named_scope :query, lambda { |query|
    { :conditions => [ "doi like ?", "%#{query}%" ] }
  }
  
  named_scope :cited, { 
    :include => :retrievals, 
    :conditions => "retrievals.citations_count > 0 or retrievals.other_citations_count > 0" 
  }

  named_scope :limit, lambda { |limit| (limit > 0) ? {:limit => limit} : {} }

  named_scope :stale_and_published, { 
    :conditions => ["exists(select retrievals.id from retrievals join sources on retrievals.source_id = sources.id where retrievals.article_id = articles.id and retrievals.retrieved_at < CONVERT_TZ(FROM_UNIXTIME(UNIX_TIMESTAMP() - sources.staleness), '-08:00', '+00:00') and sources.active = 1) and articles.published_on <= ?", Date.today ],
    :order => :retrieved_at 
  }

  def to_param
    DOI::to_uri(doi)
  end

  def doi=(new_doi)
    write_attribute :doi, DOI::from_uri(new_doi)
  end

  def stale?
    return (new_record? or (retrievals.active_sources.any? {|r| r.stale? }))
  end

  def refreshed!
    self.retrieved_at = Time.zone.now
    self
  end
  
  #Get citation count by group from the activerecord data
  def citations_by_group
    groupCounts = {}
    groupName = {}
    
    for ret in retrievals
      #log_debug "ret #{ret.citations_count + ret.other_citations_count} #{ret.source.name}"
      groupName[ret.source.group_id] = ret.source.group.name.downcase
      if groupCounts[ret.source.group_id] == nil then
        groupCounts[ret.source.group_id] = ret.citations_count + ret.other_citations_count
      else
        groupCounts[ret.source.group_id] = groupCounts[ret.source.group_id] + ret.citations_count + ret.other_citations_count
      end
    end
    
    #SQL to get the above data if we ever need it:
    #sql = "select g.id as group_id, g.name, sum(r.citations_count + r.other_citations_count) as total from retrievals r 
    #join sources s on r.source_id = s.id join groups g on g.id = s.group_id where r.article_id = #{id} group by g.id, g.name"
    #recRS = connection.execute(sql)
    
    result = [] 
    
    groupCounts.each do | key, value |
      result << {
        :group_id => key,
        :name => groupName[key],
        :total => value
      }
    end
    result
  end
  
  #Get cites for the given source from the activeRecord data
  def get_cites_by_group(groupname)
    cites = []
    
    for ret in retrievals
      #log_debug("ret.source.group.name.downcase: #{ret.source.group.name.downcase}")
      if(ret.source.group.name.downcase == groupname.downcase && (ret.citations_count + ret.other_citations_count) > 0) then
        #Cast this to an array to get around a ruby 'singularize' bug
        cites << { :name => ret.source.name.downcase, :citations => ret.citations.to_a }
      end
    end
    
    return cites
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

  def self.load_article(uri, options={})
    # Load one article given query params, for the non-#index actions
    doi = DOI::from_uri(uri)
    Article.find_by_doi(doi, options) or raise ActiveRecord::RecordNotFound
  end
end
