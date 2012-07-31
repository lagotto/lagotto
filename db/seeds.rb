# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Load default groups
social_bookmarks = Group.find_or_create_by_name(:name => "Social Bookmarks")
citations = Group.find_or_create_by_name(:name => "Citations")
blog_entries = Group.find_or_create_by_name(:name => "Blog Entries")
statistics = Group.find_or_create_by_name(:name => "Statistics")
testing = Group.find_or_create_by_name(:name => "Testing")

# Load default sources
citeulike = Citeulike.find_or_create_by_name(  
	:name => "citeulike", 
	:display_name => "CiteULike", 
	:active => true, 
	:workers => 1,
	:group_id => social_bookmarks.id,
	:url => "http://www.citeulike.org/api/posts/for/doi/%{doi}" )
  
pubmed = PubMed.find_or_create_by_name(  
  :name => "pubmed", 
  :display_name => "PubMed", 
  :active => true, 
  :workers => 1,
  :group_id => citations.id,
  :url => "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}")

  # Load sample articles
  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.ppat.1002522",
    :title => "Biochemical Properties of Highly Neuroinvasive Prion Strains",
    :published_on => "2012-02-02")
  
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
