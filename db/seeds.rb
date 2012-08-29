# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Load default groups
#usage = Group.find_or_create_by_name(:name => "Article Usage")
#citations = Group.find_or_create_by_name(:name => "Citations")
#social_networks = Group.find_or_create_by_name(:name => "Social Networks")
#blogs_media = Group.find_or_create_by_name(:name => "Blogs and Media Coverage")

# Load new sources
wikipedia = Wikipedia.find_or_create_by_name(  
  :name => "wikipedia", 
  :display_name => "Wikipedia", 
  :active => true, 
  :workers => 1,
  :group_id => citations.id,
  :url => "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}&maxlag=%{maxlag}")
