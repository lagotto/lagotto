# encoding: UTF-8
# Load sources
viewed = Group.find_by_name("viewed")
saved = Group.find_by_name("saved")
discussed = Group.find_by_name("discussed")
cited = Group.find_by_name("cited")
recommended = Group.find_by_name("recommended")
other = Group.find_by_name("other")

# The following sources require passwords/API keys and are installed by default
crossref = CrossRef.find_or_create_by_name(
  :name => "crossref",
  :display_name => "CrossRef",
  :description => "CrossRef is a non-profit organization that enables cross-publisher citation linking.",
  :state_event => "activate",
  :group_id => cited.id,
  :username => nil,
  :password => nil)
mendeley = Mendeley.find_or_create_by_name(
  :name => "mendeley",
  :display_name => "Mendeley",
  :description => "Mendeley is a reference manager and social bookmarking tool.",
  :state_event => "activate",
  :group_id => saved.id,
  :api_key => nil)
facebook = Facebook.find_or_create_by_name(
  :name => "facebook",
  :display_name => "Facebook",
  :description => "Facebook is the largest social network.",
  :state_event => "activate",
  :group_id => discussed.id,
  :access_token => nil)
researchblogging = Researchblogging.find_or_create_by_name(
  :name => "researchblogging",
  :display_name => "Research Blogging",
  :description => "Research Blogging is a science blog aggregator.",
  :state_event => "activate",
  :group_id => discussed.id,
  :username => nil,
  :password => nil)

# The following sources require passwords/API keys and are not installed by default
pmc = Pmc.find_or_create_by_name(
  :name => "pmc",
  :display_name => "PubMed Central Usage Stats",
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :queueable => false,
  :group_id => viewed.id,
  :url => nil,
  :journals => nil,
  :username => nil,
  :password => nil)
copernicus = Copernicus.find_or_create_by_name(
  :name => "copernicus",
  :display_name => "Copernicus",
  :description => "Usage stats for Copernicus articles.",
  :group_id => viewed.id,
  :url => nil,
  :username => nil,
  :password => nil)