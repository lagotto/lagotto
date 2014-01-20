# encoding: UTF-8
# Load private sources
counter = Counter.find_or_create_by_name(
  :name => "counter",
  :display_name => "Counter",
  :description => "Usage stats from the PLOS website",
  :state_event => "activate",
  :queueable => false,
  :group_id => viewed.id)
wos = Wos.find_or_create_by_name(
  :name => "wos",
  :display_name => "Web of Science",
  :description => "Web of Science is an online academic citation index.",
  :private => 1,
  :workers => 1,
  :group_id => cited.id)
scopus = Scopus.find_or_create_by_name(
  :name => "scopus",
  :display_name => "Scopus",
  :description => "The world's largest abstract and citation database of peer-reviewed literature.",
  :group_id => cited.id,
  :username => "<%= node[:alm][:scopus][:username] %>",
  :salt => "<%= node[:alm][:scopus][:salt] %>",
  :partner_id => "<%= node[:alm][:scopus][:partner_id] %>")
f1000 = F1000.find_or_create_by_name(
  :name => "f1000",
  :display_name => "F1000Prime",
  :description => "Post-publication peer review of the biomedical literature.",
  :state_event => "install",
  :group_id => recommended.id)
figshare = Figshare.find_or_create_by_name(
  :name => "figshare",
  :display_name => "Figshare",
  :description => "Figures, tables and supplementary files hosted by figshare",
  :state_event => "install",
  :group_id => viewed.id)
articleconverage = ArticleCoverage.find_or_create_by_name(
  :name => "articlecoverage",
  :display_name => "Article Coverage",
  :description => "Article Coverage",
  :group_id => discussed.id)
articlecoveragecurated = ArticleCoverageCurated.find_or_create_by_name(
  :name => "articlecoveragecurated",
  :display_name => "Article Coverage Curated",
  :description => "Article Coverage Curated",
  :state_event => "activate",
  :group_id => discussed.id)
plos_comments = PlosComments.find_or_create_by_name(
  :name => "plos_comments",
  :display_name => "Journal Comments",
  :description => "Comments from the PLOS website.",
  :state_event => "activate",
  :group_id => discussed.id)

# These sources are retired, but we need to keep them around for the data we collected
connotea = Connotea.find_or_create_by_name(
  :name => "connotea",
  :display_name => "Connotea",
  :description => "A free online reference management service for scientists, researchers, and clinicians (discontinued March 2013)",
  :group_id => discussed.id)
postgenomic = Postgenomic.find_or_create_by_name(
  :name => "postgenomic",
  :display_name => "Postgenomic",
  :description => "A science blog aggregator (discontinued)",
  :group_id => discussed.id)