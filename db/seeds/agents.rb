# Load groups
viewed = Group.where(name: 'viewed').first_or_create(title: 'Viewed')
saved = Group.where(name: 'saved').first_or_create(title: 'Saved')
discussed = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
cited = Group.where(name: 'cited').first_or_create(title: 'Cited')
recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')
other = Group.where(name: 'other').first_or_create(title: 'Other')

Source.where(name: 'citeulike').first_or_create(
  :title => 'CiteULike',
  :description => 'CiteULike is a free social bookmarking service for scholarly content.',
  :group_id => saved.id)
Source.where(name: 'pubmed').first_or_create(
  :title => 'PubMed Central',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :group_id => cited.id)
Source.where(name: 'wordpress').first_or_create(
  :title => 'Wordpress.com',
  :description => 'Wordpress.com is one of the largest blog hosting platforms.',
  :group_id => discussed.id)
Source.where(name: 'reddit').first_or_create(
  :title => 'Reddit',
  :description => 'User-generated news links.',
  :group_id => discussed.id)
Source.where(name: 'wikipedia').first_or_create(
  :title => 'Wikipedia',
  :description => 'Wikipedia is a free encyclopedia that everyone can edit.',
  :group_id => discussed.id)
Source.where(name: 'datacite').first_or_create(
  :title => 'DataCite',
  :description => 'Helping you to find, access, and reuse research data.',
  :group_id => cited.id)
Source.where(name: 'pmceurope').first_or_create(
  :title => 'Europe PubMed Central',
  :description => 'Europe PubMed Central (Europe PMC) is an archive of life ' \
                  'sciences journal literature.',
  :group_id => cited.id)
Source.where(name: 'pmceuropedata').first_or_create(
  :title => 'Europe PubMed Central Database Citations',
  :description => 'Europe PubMed Central (Europe PMC) Database is an archive of ' \
                  'life sciences journal data.',
  :eventable => false,
  :group_id => cited.id)
Source.where(name: 'scienceseeker').first_or_create(
  :title => 'ScienceSeeker',
  :description => 'Research Blogging is a science blog aggregator.',
  :group_id => discussed.id)
Source.where(name: 'nature').first_or_create(
  :title => 'Nature Blogs',
  :description => 'Nature Blogs is a science blog aggregator.',
  :group_id => discussed.id)
Source.where(name: 'openedition').first_or_create(
  :title => 'OpenEdition',
  :description => 'OpenEdition is the umbrella portal for OpenEdition Books, ' \
                  'Revues.org, Hypotheses and Calenda in the humanities and ' \
                  'social sciences.',
  :group_id => discussed.id)
Source.where(name: 'datacite_related').first_or_create(
  :title => 'DataCite Related',
  :description => 'Import works with relatedIdentifiers via the DataCite Solr API.',
  :group_id => cited.id)
Source.where(name: 'datacite_orcid').first_or_create(
  :title => 'DataCite ORCID',
  :description => 'Import works with ORCID nameIdentifier via the DataCite Solr API.',
  :group_id => saved.id)
Source.where(name: 'datacite_github').first_or_create(
  :title => 'DataCite Github',
  :description => 'Import works with Github relatedIdentifiers via the DataCite Solr API.',
  :group_id => saved.id)
Source.where(name: 'crossref_orcid').first_or_create(
  :title => 'CrossRef ORCID',
  :description => 'Import works with ORCID identifiers via the CrossRef REST API.',
  :group_id => saved.id)

# The following sources require passwords/API keys and are installed by default
Source.where(name: 'crossref').first_or_create(
  :title => 'CrossRef',
  :description => 'CrossRef is a non-profit organization that enables ' \
                  'cross-publisher citation linking.',
  :group_id => cited.id)
Source.where(name: 'scopus').first_or_create(
  :title => 'Scopus',
  :description => 'Scopus is an abstract and citation database of peer-' \
                  'reviewed literature.',
  :eventable => false,
  :group_id => cited.id)
Source.where(name: 'mendeley').first_or_create(
  :title => 'Mendeley',
  :description => 'Mendeley is a reference manager and social bookmarking tool.',
  :eventable => false,
  :group_id => saved.id)
Source.where(name: 'facebook').first_or_create(
  :title => 'Facebook',
  :description => 'Facebook is the largest social network.',
  :eventable => false,
  :group_id => discussed.id)
Source.where(name: 'researchblogging').first_or_create(
  :title => 'Research Blogging',
  :description => 'Research Blogging is a science blog aggregator.',
  :group_id => discussed.id)
Source.where(name: 'pmc').first_or_create(
  :title => 'PubMed Central Usage Stats',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :eventable => false,
  :group_id => viewed.id)
Source.where(name: 'copernicus').first_or_create(
  :title => 'Copernicus',
  :description => 'Usage stats for Copernicus articles.',
  :eventable => false,
  :group_id => viewed.id)
Source.where(name: 'twitter').first_or_create(
  :title => 'Twitter',
  :description => 'Twitter is a social networking and microblogging service.',
  :group_id => discussed.id)
Source.where(name: 'counter').first_or_create(
  :title => "Counter",
  :description => "Publisher usage stats following COUNTER standard",
  :eventable => false,
  :group_id => viewed.id)
Source.where(name: 'wos').first_or_create(
  :title => "Web of Science",
  :description => "Web of Science is an online academic citation index.",
  :private => true,
  :eventable => false,
  :group_id => cited.id)
Source.where(name: 'f1000').first_or_create(
  :title => "F1000Prime",
  :description => "Post-publication peer review of the biomedical literature.",
  :eventable => false,
  :group_id => recommended.id)
Source.where(name: 'figshare').first_or_create(
  :title => "Figshare",
  :description => "Figures, tables and supplementary files hosted by figshare",
  :eventable => false,
  :group_id => viewed.id)
Source.where(name: 'articlecoverage').first_or_create(
  :title => "Article Coverage",
  :description => "Article Coverage",
  :eventable => false,
  :group_id => other.id)
Source.where(name: 'articlecoveragecurated').first_or_create(
  :title => "Article Coverage Curated",
  :description => "Article Coverage Curated",
  :group_id => other.id)
Source.where(name: 'plos_comments').first_or_create(
  :title => "Journal Comments",
  :description => "Comments from the PLOS website.",
  :group_id => discussed.id)
Source.where(name: 'github').first_or_create(
  :title => 'Github',
  :description => 'GitHub is a web-based Git repository hosting service.',
  :group_id => saved.id)
Source.where(name: 'bitbucket').first_or_create(
  :title => 'Bitbucket',
  :description => 'Bitbucket is a web-based repository hosting service using git and mercurial.',
  :eventable => false,
  :group_id => saved.id)
Source.where(name: 'ads').first_or_create(
  :title => "ADS",
  :description => "Astrophysics Data System.",
  :group_id => cited.id)
Source.where(name: 'ads_fulltext').first_or_create(
  :title => "ADS Fulltext",
  :description => "Astrophysics Data System Fulltext Search.",
  :group_id => cited.id)

# These sources are installed and activated by default
Citeulike.where(name: 'citeulike').first_or_create(
  :title => 'CiteULike',
  :description => 'CiteULike is a free social bookmarking service for scholarly content.',
  :state_event => 'activate',
  :source_id => "citeulike",
  :group_id => saved.id)
PubMed.where(name: 'pubmed').first_or_create(
  :title => 'PubMed Central',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :state_event => 'activate',
  :source_id => "pubmed",
  :group_id => cited.id)
Wordpress.where(name: 'wordpress').first_or_create(
  :title => 'Wordpress.com',
  :description => 'Wordpress.com is one of the largest blog hosting platforms.',
  :state_event => 'activate',
  :source_id => "wordpress",
  :group_id => discussed.id)
Reddit.where(name: 'reddit').first_or_create(
  :title => 'Reddit',
  :description => 'User-generated news links.',
  :state_event => 'activate',
  :source_id => "reddit",
  :group_id => discussed.id)
Wikipedia.where(name: 'wikipedia').first_or_create(
  :title => 'Wikipedia',
  :description => 'Wikipedia is a free encyclopedia that everyone can edit.',
  :state_event => 'activate',
  :source_id => "wikipedia",
  :group_id => discussed.id)
Datacite.where(name: 'datacite').first_or_create(
  :title => 'DataCite',
  :description => 'Helping you to find, access, and reuse research data.',
  :source_id => "datacite",
  :group_id => cited.id)
DataciteData.where(name: 'datacite_data').first_or_create(
  :title => 'DataCite Data',
  :description => 'Helping you to find, access, and reuse research data.',
  :source_id => "datacite_data",
  :group_id => cited.id)

# These sources are not installed by default
EuropePmc.where(name: 'pmc_europe').first_or_create(
  :title => 'Europe PMC',
  :description => 'Europe PubMed Central (Europe PMC) is an archive of life ' \
                  'sciences journal literature.',
  :source_id => "pmc_europe",
  :group_id => cited.id)
EuropePmcData.where(name: 'pmc_europe_data').first_or_create(
  :title => 'Europe PMC Database Citations',
  :description => 'Europe PubMed Central (Europe PMC) Database is an archive of ' \
                  'life sciences journal data.',
  :source_id => "pmc_europe_data",
  :group_id => cited.id)
EuropePmcFulltext.where(name: 'europe_pmc_fulltext').first_or_create(
  :title => 'Europe PMC Fulltext Search',
  :description => 'Search the Europe PMC fulltext corpus for citations.',
  :source_id => "europe_pmc_fulltext",
  :group_id => cited.id)
ScienceSeeker.where(name: 'scienceseeker').first_or_create(
  :title => 'ScienceSeeker',
  :description => 'Research Blogging is a science blog aggregator.',
  :source_id => "scienceseeker",
  :group_id => discussed.id)
Nature.where(name: 'nature').first_or_create(
  :title => 'Nature Blogs',
  :description => 'Nature Blogs is a science blog aggregator.',
  :source_id => "nature",
  :group_id => discussed.id)
Openedition.where(name: 'openedition').first_or_create(
  :title => 'OpenEdition',
  :description => 'OpenEdition is the umbrella portal for OpenEdition Books, ' \
                  'Revues.org, Hypotheses and Calenda in the humanities and ' \
                  'social sciences.',
  :source_id => "openedition",
  :group_id => discussed.id)
Github.where(name: 'github').first_or_create(
  :title => 'Github',
  :description => 'GitHub is a web-based Git repository hosting service.',
  :source_id => "github",
  :group_id => saved.id)
Bitbucket.where(name: 'bitbucket').first_or_create(
  :title => 'Bitbucket',
  :description => 'Bitbucket is a web-based repository hosting service using git and mercurial.',
  :source_id => "bitbucket",
  :group_id => saved.id)
PlosFulltext.where(name: 'plos_fulltext').first_or_create(
  :title => 'PLOS Fulltext Search',
  :description => 'Search the PLOS corpus for citations.',
  :source_id => "plos_fulltext",
  :group_id => cited.id)
BmcFulltext.where(name: 'bmc_fulltext').first_or_create(
  :title => 'BMC Fulltext Search',
  :description => 'Search the BioMed Central corpus for citations.',
  :source_id => "bmc_fulltext",
  :group_id => cited.id)
NatureOpensearch.where(name: 'nature_opensearch').first_or_create(
  :title => 'Nature.com OpenSearch',
  :description => 'Search the Nature.com corpus for citations.',
  :source_id => "nature_opensearch",
  :group_id => cited.id)
Orcid.where(name: 'orcid').first_or_create(
  :title => 'ORCID',
  :description => 'ORCID is a persistent author identifier for connecting research and researchers.',
  :source_id => "orcid",
  :group_id => saved.id)
PlosImport.where(name: 'plos_import').first_or_create(
  :title => 'PLOS Import',
  :description => 'Import works via the PLOS Solr API.',
  :kind => "all",
  :group_id => other.id)
CrossrefImport.where(name: 'crossref_import').first_or_create(
  :title => 'CrossRef Import',
  :description => 'Import works via the CrossRef REST API.',
  :kind => "all",
  :group_id => other.id)
CrossrefOrcid.where(name: 'crossref_orcid').first_or_create(
  :title => 'CrossRef ORCID',
  :description => 'Import works with ORCID identifiers via the CrossRef REST API.',
  :kind => "all",
  :group_id => saved.id)
DataciteImport.where(name: 'datacite_import').first_or_create(
  :title => 'DataCite Import',
  :description => 'Import works via the DataCite Solr API.',
  :kind => "all",
  :group_id => other.id)
DataciteRelated.where(name: 'datacite_related').first_or_create(
    :title => 'DataCite Related',
    :description => 'Import works with relatedIdentifiers via the DataCite Solr API.',
    :kind => "all",
    :source_id => 'datacite_related',
    :group_id => cited.id)
DataciteOrcid.where(name: 'datacite_orcid').first_or_create(
    :title => 'DataCite ORCID',
    :description => 'Import works with ORCID nameIdentifiers via the DataCite Solr API.',
    :kind => "all",
    :source_id => 'datacite_orcid',
    :group_id => saved.id)
DataciteGithub.where(name: 'datacite_github').first_or_create(
    :title => 'DataCite Github',
    :description => 'Import works with Github relatedIdentifiers via the DataCite Solr API.',
    :kind => "all",
    :source_id => 'datacite_github',
    :group_id => saved.id)
DataoneImport.where(name: 'dataone_import').first_or_create(
  :title => 'DataONE Import',
  :description => 'Import works via the DataONE Solr API.',
  :kind => "all",
  :group_id => other.id)

# The following sources require passwords/API keys and are installed by default
CrossRef.where(name: 'crossref').first_or_create(
  :title => 'CrossRef',
  :description => 'CrossRef is a non-profit organization that enables ' \
                  'cross-publisher citation linking.',
  :source_id => "crossref",
  :group_id => cited.id,
  :state_event => 'install',
  :username => nil,
  :password => nil)
Scopus.where(name: 'scopus').first_or_create(
  :title => 'Scopus',
  :description => 'Scopus is an abstract and citation database of peer-' \
                  'reviewed literature.',
  :source_id => "scopus",
  :group_id => cited.id,
  :api_key => nil,
  :insttoken => nil)
Mendeley.where(name: 'mendeley').first_or_create(
  :title => 'Mendeley',
  :description => 'Mendeley is a reference manager and social bookmarking tool.',
  :source_id => "mendeley",
  :group_id => saved.id,
  :state_event => 'install',
  :api_key => nil)
Facebook.where(name: 'facebook').first_or_create(
  :title => 'Facebook',
  :description => 'Facebook is the largest social network.',
  :source_id => "facebook",
  :group_id => discussed.id,
  :state_event => 'install',
  :access_token => nil)
Researchblogging.where(name: 'researchblogging').first_or_create(
  :title => 'Research Blogging',
  :description => 'Research Blogging is a science blog aggregator.',
  :source_id => "researchblogging",
  :group_id => discussed.id,
  :username => nil,
  :password => nil)

# The following sources require passwords/API keys and are not installed by default
Pmc.where(name: 'pmc').first_or_create(
  :title => 'PubMed Central Usage Stats',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :source_id => "pmc",
  :group_id => viewed.id)
Copernicus.where(name: 'copernicus').first_or_create(
  :title => 'Copernicus',
  :description => 'Usage stats for Copernicus articles.',
  :source_id => "counter",
  :group_id => viewed.id)
TwitterSearch.where(name: 'twitter_search').first_or_create(
  :title => 'Twitter (Search API)',
  :description => 'Twitter is a social networking and microblogging service.',
  :source_id => "twitter",
  :group_id => discussed.id)
Counter.where(name: 'counter').first_or_create(
  :title => "Counter",
  :description => "Usage stats from the PLOS website",
  :source_id => "counter",
  :group_id => viewed.id)
Wos.where(name: 'wos').first_or_create(
  :title => "Web of Science",
  :description => "Web of Science is an online academic citation index.",
  :source_id => "wos",
  :group_id => cited.id)
F1000.where(name: 'f1000').first_or_create(
  :title => "F1000Prime",
  :description => "Post-publication peer review of the biomedical literature.",
  :source_id => "f1000",
  :kind => "all",
  :group_id => recommended.id)
Figshare.where(name: 'figshare').first_or_create(
  :title => "Figshare",
  :description => "Figures, tables and supplementary files hosted by figshare",
  :source_id => "figshare",
  :group_id => viewed.id)
ArticleCoverage.where(name: 'articlecoverage').first_or_create(
  :title => "Article Coverage",
  :description => "Article Coverage",
  :source_id => "articlecoverage",
  :group_id => other.id)
ArticleCoverageCurated.where(name: 'articlecoveragecurated').first_or_create(
  :title => "Article Coverage Curated",
  :description => "Article Coverage Curated",
  :source_id => "articlecoveragecurated",
  :group_id => other.id)
PlosComments.where(name: 'plos_comments').first_or_create(
  :title => "Journal Comments",
  :description => "Comments from the PLOS website.",
  :source_id => "plos_comments",
  :group_id => discussed.id)
Ads.where(name: 'ads').first_or_create(
  :title => "ADS",
  :description => "Astrophysics Data System.",
  :source_id => "ads",
  :group_id => cited.id)
AdsFulltext.where(name: 'ads_fulltext').first_or_create(
  :title => "ADS Fulltext",
  :description => "Astrophysics Data System Fulltext Search.",
  :source_id => "ads_fulltext",
  :group_id => cited.id)
