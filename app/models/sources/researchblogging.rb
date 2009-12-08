class Researchblogging < Source
  include SourceHelper
  def uses_username; true; end
  def uses_password; true; end
  def uses_search_url; true; end
  def uses_url; true; end
  
  def public_url_base
    "http://researchblogging.org/post-search/list?article="
  end

  def query(article, options={})
    raise(ArgumentError, "Researchblogging configuration requires username & password") \
      if username.blank? or password.blank?

    furl = "#{url}?count=100&article=#{CGI.escape(article.doi)}"
    
    if(options[:verbose] > 1) 
      puts furl
    end
    
    get_xml(furl, options.merge(:username => username, :password => password, :verbose=> 0 )) do |xml|
      citations = []
      
      if(options[:verbose] > 2) 
        puts "Got XML"
      end
      
      xml.find("//blogposts/post").each do |post|
        details = {}
        
        if(options[:verbose] > 2) 
          puts "Found Post"
        end
        
        details[:title] = post.find_first("post_title").content
        details[:name] = post.find_first("blog_name").content
        details[:blogger_name] = post.find_first("blogger_name").content
        details[:publishdate] = post.find_first("published_date").content
        details[:receiveddate] = post.find_first("received_date").content
        
        citation = {}
        citation[:uri] = post.find_first("post_URL").content
        citation[:details] = details;
        
        if(options[:verbose] > 1) 
          puts citation[:uri]
        end
        
        citations << citation        
      end
      citations
    end
  end
end

