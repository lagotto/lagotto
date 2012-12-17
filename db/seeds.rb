# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Load default groups
#usage = Group.find_or_create_by_name(:name => "Article Usage")
#citations = Group.find_or_create_by_name(:name => "Citations")
#social_networks = Group.find_or_create_by_name(:name => "Social Networks")
blogs_media = Group.find_or_create_by_name(:name => "Blog Entries")

# Load default sources
# citeulike = Citeulike.find_or_create_by_name(  
#   :name => "citeulike", 
#   :display_name => "CiteULike", 
#   :active => true, 
#   :workers => 1,
#   :group_id => social_networks.id,
#   :url => "http://www.citeulike.org/api/posts/for/doi/%{doi}" )
  
scienceseeker = ScienceSeeker.find_or_create_by_name(  
	:name => "scienceseeker", 
	:display_name => "ScienceSeeker", 
	:active => true, 
	:workers => 1,
	:group_id => blogs_media.id,
	:url => "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}" )
  
# pubmed = PubMed.find_or_create_by_name(  
#   :name => "pubmed", 
#   :display_name => "PubMed", 
#   :active => true, 
#   :workers => 1,
#   :group_id => citations.id,
#   :url => "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}")
#   
#   wikipedia = Wikipedia.find_or_create_by_name(  
#     :name => "wikipedia", 
#     :display_name => "Wikipedia", 
#     :active => true, 
#     :workers => 1,
#     :group_id => citations.id,
#     :url => "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}&maxlag=%{maxlag}")
# 
#   # The following sources require passwords/API keys
#   mendeley = Mendeley.find_or_create_by_name(  
#     :name => "mendeley", 
#     :display_name => "Mendeley", 
#     :active => false, 
#     :workers => 1,
#     :group_id => social_networks.id,
#     :url => "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}",
#     :url_with_type => "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}",
#     :related_articles_url => "http://api.mendeley.com/oapi/documents/related/%{id}",
#     :api_key => "EXAMPLE")
#   
#   crossref = CrossRef.find_or_create_by_name(  
#     :name => "crossref", 
#     :display_name => "CrossRef", 
#     :active => false, 
#     :workers => 1,
#     :group_id => citations.id,
#     :default_url => "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true",
#     :url => "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}",
#     :username => "EXAMPLE",
#     :password => "EXAMPLE")
#   
#   facebook = Facebook.find_or_create_by_name(  
#     :name => "facebook", 
#     :display_name => "Facebook", 
#     :active => false, 
#     :workers => 1,
#     :group_id => social_networks.id,
#     :api_key => "EXAMPLE")
#   
#   nature = Nature.find_or_create_by_name(  
#     :name => "nature", 
#     :display_name => "Nature Blogs", 
#     :active => false, 
#     :workers => 1,
#     :group_id => blogs_media.id,
#     :url => "http://api.nature.com/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}",
#     :api_key => "EXAMPLE")
#     
#   researchblogging = Researchblogging.find_or_create_by_name(  
#     :name => "researchblogging", 
#     :display_name => "Research Blogging", 
#     :active => false, 
#     :workers => 1,
#     :group_id => blogs_media.id,
#     :url => "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}",
#     :username => "EXAMPLE",
#     :password => "EXAMPLE")
