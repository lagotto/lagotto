# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Load default admin user
User.create(:username => "voldemort", :email => "admin@plos.org", :password => "voldemort", :password_confirmation => "voldemort") if User.count == 0

# Load default groups
usage = Group.find_or_create_by_name(:name => "Article Usage")
citations = Group.find_or_create_by_name(:name => "Citations")
social_networks = Group.find_or_create_by_name(:name => "Social Networks")
blogs_media = Group.find_or_create_by_name(:name => "Blogs and Media Coverage")

# Load default sources
citeulike = Citeulike.find_or_create_by_name(  
	:name => "citeulike", 
	:display_name => "CiteULike", 
  :description => "CiteULike is a free social bookmarking service for scholarly content.",
	:active => true, 
	:workers => 1,
	:group_id => social_networks.id,
	:url => "http://www.citeulike.org/api/posts/for/doi/%{doi}" )
pubmed = PubMed.find_or_create_by_name(  
  :name => "pubmed", 
  :display_name => "PubMed", 
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :active => true, 
  :workers => 1,
  :group_id => citations.id,
  :url => "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}")
scienceseeker = ScienceSeeker.find_or_create_by_name(  
	:name => "scienceseeker", 
	:display_name => "ScienceSeeker", 
  :description => "Research Blogging is a science blog aggregator.",
	:active => true, 
	:workers => 1,
	:group_id => blogs_media.id,
	:url => "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}" )
  
wikipedia = Wikipedia.find_or_create_by_name(  
  :name => "wikipedia", 
  :display_name => "Wikipedia", 
  :description => "Wikipedia is a free encyclopedia that everyone can edit.",
  :active => true, 
  :workers => 1,
  :group_id => citations.id,
  :url => "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=0srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1")
wos = Wos.find_or_create_by_name(  
	:name => "wos", 
	:display_name => "Web of Science", 
  :description => "Web of Science is an online academic citation index.",
	:active => true, 
	:workers => 1,
	:group_id => citations.id,
	:url => "https://ws.isiknowledge.com/cps/xrpc" )

# The following sources require passwords/API keys
counter = Counter.find_or_create_by_name(  
  :name => "counter", 
  :display_name => "Counter", 
  :description => "Usage stats from the PLOS website",
  :active => true, 
  :workers => 1,
  :group_id => usage.id,
  :url => "http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}")


crossref = CrossRef.find_or_create_by_name(  
  :name => "crossref", 
  :display_name => "CrossRef", 
  :description => "CrossRef is a non-profit organization that enables cross-publisher citation linking.",
  :active => true, 
  :workers => 1,
  :group_id => citations.id,
  :default_url => "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true",
  :url => "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}",
  :username => "plos",
  :password => "plos1")
  
facebook = Facebook.find_or_create_by_name(  
  :name => "facebook", 
  :display_name => "Facebook", 
  :description => "Facebook is the largest social network.",
  :active => true, 
  :workers => 1,
  :group_id => social_networks.id,
  :url => "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, normalized_url, share_count, like_count, comment_count, total_count, click_count, comments_fbid, commentsbox_count from link_stat where url = '%{query_url}'",
  :access_token => "318375554854773|tNMX2gWP_tTaah0p1Nf4ZFF4A5Q")
  
mendeley = Mendeley.find_or_create_by_name(  
  :name => "mendeley", 
  :display_name => "Mendeley", 
  :description => "Mendeley is a reference manager and social bookmarking tool.",
  :active => true, 
  :workers => 1,
  :group_id => social_networks.id,
  :url => "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}",
  :url_with_type => "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}",
  :url_with_title => "http://api.mendeley.com/oapi/documents/search/title:%{title}/?items=10&consumer_key=%{api_key}",
  :related_articles_url => "http://api.mendeley.com/oapi/documents/related/%{id}?consumer_key=%{api_key}",
  :api_key => "dcd28c9a2ed8cd145533731ebd3278e504c06f3d5")
  
nature = Nature.find_or_create_by_name(  
  :name => "nature", 
  :display_name => "Nature Blogs", 
  :description => "Nature Blogs is a science blog aggregator.",
  :active => true, 
  :workers => 1,
  :group_id => blogs_media.id,
  :url => "http://api.nature.com/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}",
  :api_key => "7jug74j8rh49n8rbn8atwyec")
  
pmc = Pmc.find_or_create_by_name(  
  :name => "pmc", 
  :display_name => "PubMed Central Usage Stats", 
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :active => true, 
  :workers => 1,
  :group_id => usage.id,
  :url => "http://localhost:5984/pmc_usage_stats/%{doi}",
  :filepath => "/home/alm/pmcdata/")
    
researchblogging = Researchblogging.find_or_create_by_name(  
  :name => "researchblogging", 
  :display_name => "Research Blogging", 
  :description => "Research Blogging is a science blog aggregator.",
  :active => true, 
  :workers => 1,
  :group_id => blogs_media.id,
  :url => "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}",
  :username => "plosuser",
  :password => "siWSaA546pM")
  
# Load sample articles
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0008776",
  :title => "The \"Island Rule\" and Deep-Sea Gastropods: Re-Examining the Evidence",
  :published_on => "2010-01-19")
  
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pcbi.1000204",
  :title => "Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web",
  :published_on => "2008-10-31")
    
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0018657",
  :title => "Who Shares? Who Doesn't? Factors Associated with Openly Archiving Raw Research Data",
  :published_on => "2011-07-13")
    
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pcbi.0010057",
  :title => "Ten Simple Rules for Getting Published",
  :published_on => "2005-10-28")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0000443",
  :title => "Order in Spontaneous Behavior",
  :published_on => "2007-05-16")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pbio.1000242",
  :title => "Article-Level Metrics and the Evolution of Scientific Impact",
  :published_on => "2009-11-17")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0035869",
  :title => "Research Blogs and the Discussion of Scholarly Information",
  :published_on => "2012-05-11")
          
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pmed.0020124",
  :title => "Why Most Published Research Findings Are False",
  :published_on => "2005-08-30")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0036240",
  :title => "How Academic Biologists and Physicists View Science Outreach",
  :published_on => "2012-05-09")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0000000",
  :title => "PLoS Journals Sandbox: A Place to Learn and Play",
  :published_on => "2006-12-20")
	  
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pmed.0020146",
  :title => "How Prevalent Is Schizophrenia?",
  :published_on => "2005-05-31")
		
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pbio.0030137",
  :title => "Perception Space-The Final Frontier",
  :published_on => "2005-04-12")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pcbi.1002445",
  :title => "Circular Permutation in Proteins",
  :published_on => "2012-03-29")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0036790",
  :title => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
  :published_on => "2012-05-15")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pbio.0060188",
  :title => "Going, Going, Gone: Is Animal Migration Disappearing",
  :published_on => "2008-07-29")
        
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0001636",
  :title => "Measuring the Meltdown: Drivers of Global Amphibian Extinction and Decline",
  :published_on => "2008-02-20")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pone.0006872",
  :title => "Persistent Exposure to Mycoplasma Induces Malignant Transformation of Human Prostate Cells",
  :published_on => "2009-09-01")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pcbi.0020131",
  :title => "Sampling Realistic Protein Conformations Using Local Structural Bias",
  :published_on => "2006-09-22")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pbio.0040015",
  :title => "Thriving Community of Pathogenic Plant Viruses Found in the Human Gut",
  :published_on => "2005-12-20")
      
Article.find_or_create_by_doi(
  :doi => "10.1371/journal.pbio.0020413",
  :title => "Taking Stock of Biodiversity to Stem Its Rapid Decline",
  :published_on => "2004-10-26")
  
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-5-1053-2005",
  :title => "Organic aerosol and global climate modelling: a review",
  :published_on => "2005-03-30")
  
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-11-9709-2011",
  :title => "Modelling atmospheric OH-reactivity in a boreal forest ecosystem",
  :published_on => "2011-09-20")
    
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-11-13325-2011",
  :title => "Comparison of chemical characteristics of 495 biomass burning plumes intercepted by the NASA DC-8 aircraft during the ARCTAS/CARB-2008 field campaign",
  :published_on => "2011-12-22")
      
Article.find_or_create_by_doi(
  :doi => "10.5194/acp-12-1-2012",
  :title => "A review of operational, regional-scale, chemical weather forecasting models in Europe",
  :published_on => "2012-01-02")
        
Article.find_or_create_by_doi(
  :doi => "10.5194/se-1-1-2010",
  :title => "The Eons of Chaos and Hades",
  :published_on => "2010-02-02")
