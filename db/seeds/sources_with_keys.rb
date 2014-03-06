# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).


# Load sources
viewed = Group.find_or_create_by_name(name: "viewed", display_name: "Viewed")
saved = Group.find_or_create_by_name(name: "saved", display_name: "Saved")
discussed = Group.find_or_create_by_name(name: "discussed", display_name: "Discussed")
cited = Group.find_or_create_by_name(name: "cited", display_name: "Cited")
recommended = Group.find_or_create_by_name(name: "recommended", display_name: "Recommended")
other = Group.find_or_create_by_name(name: "other", display_name: "Other")

# The following sources require passwords, API keys and/or contracts
pmc = Pmc.find_or_create_by_name(
  :name => "pmc",
  :display_name => "PubMed Central Usage Stats",
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :queueable => false,
  :group_id => viewed.id,
  :url => "http://127.0.0.1:5984/pmc_usage_stats/",
  :journals => "plosbiol,plosmed,ploscomp,plosgen,plospath,plosone,plosntd,plosct,ploscurrents",
  :username => "plospubs",
  :password => "er56nm")
copernicus = Copernicus.find_or_create_by_name(
  :name => "copernicus",
  :display_name => "Copernicus",
  :description => "Usage stats for Copernicus articles.",
  :group_id => viewed.id,
  :url => "http://editor.copernicus.org/api/v1/articleStatisticsDoi/doi:%{doi}.json",
  :username => "harvester",
  :password => "bQ_99!-O=tXc")
crossref = CrossRef.find_or_create_by_name(
  :name => "crossref",
  :display_name => "CrossRef",
  :description => "CrossRef is a non-profit organization that enables cross-publisher citation linking.",
  :group_id => cited.id,
  :username => "plos",
  :password => "plos1")
scopus = Scopus.find_or_create_by_name(
  :name => "scopus",
  :display_name => "Scopus",
  :description => "Scopus is an abstract and citation database of peer-reviewed literature.",
  :group_id => cited.id,
  :api_key => "13d2f5fc673aca2a725b7db8d18651fa",
  :insttoken => "9a2a694bed39b51f25cc0ed5ea5c921b")
facebook = Facebook.find_or_create_by_name(
  :name => "facebook",
  :display_name => "Facebook",
  :description => "Facebook is the largest social network.",
  :group_id => discussed.id,
  :access_token => "318375554854773|tNMX2gWP_tTaah0p1Nf4ZFF4A5Q")
mendeley = Mendeley.find_or_create_by_name(
  :name => "mendeley",
  :display_name => "Mendeley",
  :description => "Mendeley is a reference manager and social bookmarking tool.",
  :group_id => saved.id,
  :api_key => "dcd28c9a2ed8cd145533731ebd3278e504c06f3d5")
researchblogging = Researchblogging.find_or_create_by_name(
  :name => "researchblogging",
  :display_name => "Research Blogging",
  :description => "Research Blogging is a science blog aggregator.",
  :group_id => discussed.id,
  :username => "plosuser",
  :password => "siWSaA546pM")
twitter_search = TwitterSearch.find_or_create_by_name(
  :name => "twitter_search",
  :display_name => "Twitter",
  :description => "Twitter is a social networking and microblogging service.",
  :group_id => discussed.id,
  :access_token => "")