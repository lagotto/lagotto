# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).


# Load default groups
viewed = Group.find_or_create_by_name(:name => "Viewed")
cited = Group.find_or_create_by_name(:name => "Cited")
saved = Group.find_or_create_by_name(:name => "Saved")
discussed = Group.find_or_create_by_name(:name => "Discussed")
recommended = Group.find_or_create_by_name(:name => "Recommended")
other = Group.find_or_create_by_name(:name => "Other")

# Load default reports
daily_report = Report.find_or_create_by_name(:name => "Daily Report")

# Load default filters
article_not_updated_error = ArticleNotUpdatedError.find_or_create_by_name(
  :name => "ArticleNotUpdatedError",
  :display_name => "article not updated error",
  :description => "Raises an error if articles have not been updated within the specified interval in days.")
event_count_decreasing_error = EventCountDecreasingError.find_or_create_by_name(
  :name => "EventCountDecreasingError",
  :display_name => "decreasing event count error",
  :description => "Raises an error if event count decreases.")
event_count_increasing_too_fast_error = EventCountIncreasingTooFastError.find_or_create_by_name(
  :name => "EventCountIncreasingTooFastError",
  :display_name => "increasing event count error",
  :description => "Raises an error if the event count increases faster than the specified value per day.")
api_response_too_slow_error = ApiResponseTooSlowError.find_or_create_by_name(
  :name => "ApiResponseTooSlowError",
  :display_name => "API too slow error",
  :description => "Raises an error if an API response takes longer than the specified interval in seconds.")
source_not_updated_error = SourceNotUpdatedError.find_or_create_by_name(
  :name => "SourceNotUpdatedError",
  :display_name => "source not updated error",
  :description => "Raises an error if a source has not been updated in 24 hours.")
citation_milestone_alert = CitationMilestoneAlert.find_or_create_by_name(
  :name => "CitationMilestoneAlert",
  :display_name => "citation milestone alert",
  :description => "Creates an alert if an article has been cited the specified number of times.")

# Load default sources
citeulike = Citeulike.find_or_create_by_name(
	:name => "citeulike",
	:display_name => "CiteULike",
  :description => "CiteULike is a free social bookmarking service for scholarly content.",
	:state_event => "activate",
	:workers => 1,
	:group_id => saved.id,
	:url => "http://www.citeulike.org/api/posts/for/doi/%{doi}" )
pubmed = PubMed.find_or_create_by_name(
  :name => "pubmed",
  :display_name => "PubMed",
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :state_event => "activate",
  :workers => 1,
  :group_id => cited.id,
  :url => "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}")
pmc_europe = PmcEurope.find_or_create_by_name(
  :name => "pmceurope",
  :display_name => "PMC Europe Citations",
  :description => "Europe PubMed Central (Europe PMC) is an archive of life sciences journal literature.",
  :state_event => "activate",
  :workers => 1,
  :group_id => cited.id,
  :url => "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pub_med}/citations/1/json")
pmc_europe_data = PmcEuropeData.find_or_create_by_name(
  :name => "pmceuropedata",
  :display_name => "PMC Europe Database Citations",
  :description => "Europe PubMed Central (Europe PMC) is an archive of life sciences journal literature.",
  :state_event => "activate",
  :workers => 1,
  :group_id => cited.id,
  :url => "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pub_med}/databaseLinks//1/json")
scienceseeker = ScienceSeeker.find_or_create_by_name(
	:name => "scienceseeker",
	:display_name => "ScienceSeeker",
  :description => "Research Blogging is a science blog aggregator.",
	:state_event => "activate",
	:workers => 1,
	:group_id => discussed.id,
	:url => "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}" )

nature = Nature.find_or_create_by_name(
  :name => "nature",
  :display_name => "Nature Blogs",
  :description => "Nature Blogs is a science blog aggregator.",
  :state_event => "activate",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://blogs.nature.com/posts.json?doi=%{doi}")

openedition = Openedition.find_or_create_by_name(
  :name => "openedition",
  :display_name => "OpenEdition",
  :description => "OpenEdition is the umbrella portal for OpenEdition Books, Revues.org, Hypotheses and Calenda, four platforms dedicated to electronic resources in the humanities and social sciences.",
  :state_event => "activate",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://search.openedition.org/feed.php?op[]=AND&q[]=%{query_url}&field[]=All&pf=Hypotheses.org")

wordpress = Wordpress.find_or_create_by_name(
  :name => "wordpress",
  :display_name => "Wordpress.com",
  :description => "Wordpress.com is one of the largest blog hosting platforms.",
  :state_event => "activate",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://en.search.wordpress.com/?q=\"%{doi}\"&t=post&f=json")

reddit = Reddit.find_or_create_by_name(
  :name => "reddit",
  :display_name => "Reddit",
  :description => "User-generated news links.",
  :state_event => "activate",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://www.reddit.com/search.json?q=\"%{id}\"")

wikipedia = Wikipedia.find_or_create_by_name(
  :name => "wikipedia",
  :display_name => "Wikipedia",
  :description => "Wikipedia is a free encyclopedia that everyone can edit.",
  :state_event => "activate",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1")

# The following sources require passwords/API keys


crossref = CrossRef.find_or_create_by_name(
  :name => "crossref",
  :display_name => "CrossRef",
  :description => "CrossRef is a non-profit organization that enables cross-publisher citation linking.",
  :state_event => "",
  :workers => 1,
  :group_id => cited.id,
  :default_url => "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true",
  :url => "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}",
  :username => "EXAMPLE",
  :password => "EXAMPLE")

facebook = Facebook.find_or_create_by_name(
  :name => "facebook",
  :display_name => "Facebook",
  :description => "Facebook is the largest social network.",
  :state_event => "",
  :workers => 1,
  :group_id => discussed.id,
  :url => "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, normalized_url, share_count, like_count, comment_count, total_count, click_count, comments_fbid, commentsbox_count from link_stat where url = '%{query_url}'",
  :access_token => "EXAMPLE")

mendeley = Mendeley.find_or_create_by_name(
  :name => "mendeley",
  :display_name => "Mendeley",
  :description => "Mendeley is a reference manager and social bookmarking tool.",
  :state_event => "",
  :workers => 1,
  :group_id => saved.id,
  :url => "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}",
  :url_with_type => "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}",
  :url_with_title => "http://api.mendeley.com/oapi/documents/search/%{title}/?items=10&consumer_key=%{api_key}",
  :related_articles_url => "http://api.mendeley.com/oapi/documents/related/%{id}?consumer_key=%{api_key}",
  :api_key => "EXAMPLE")

researchblogging = Researchblogging.find_or_create_by_name(
  :name => "researchblogging",
  :display_name => "Research Blogging",
  :description => "Research Blogging is a science blog aggregator.",
  :state_event => "",
  :workers => 1,
  :group_id => discussed.id,
  :url => "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}",
  :username => "EXAMPLE",
  :password => "EXAMPLE")

# Load sample articles
if ENV['ARTICLES']
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

  Article.find_or_create_by_doi(
    :doi => "10.1590/S1413-86702012000300021",
    :title => "Terry's nails",
    :published_on => "2012-06-01")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0000045",
    :title => "The Genome Sequence of Caenorhabditis briggsae: A Platform for Comparative Genomics",
    :published_on => "2003-11-17")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0050254",
    :title => "The Diploid Genome Sequence of an Individual Human",
    :published_on => "2007-09-04")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0044271",
    :title => "Lesula: A New Species of <italic>Cercopithecus</italic> Monkey Endemic to the Democratic Republic of Congo and Implications for Conservation of Congo’s Central Basin",
    :published_on => "2012-09-12")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0033288",
    :title => "Genome Features of 'Dark-Fly', a <italic>Drosophila</italic> Line Reared Long-Term in a Dark Environment",
    :published_on => "2012-03-14")

  Article.find_or_create_by_doi(
    :doi => "10.2307/1158830",
    :title => "Histoires de riz, histoires d'igname: le cas de la Moyenne Cote d'Ivoire",
    :published_on => "1981-01-01")

  Article.find_or_create_by_doi(
    :doi => "10.2307/683422",
    :title => "Review of: The Life and Times of Sara Baartman: The Hottentot Venus by Zola Maseko",
    :published_on => "2000-09-01")
end
