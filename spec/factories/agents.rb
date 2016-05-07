FactoryGirl.define do

  factory :group do
    name 'saved'
    title 'Saved'

    initialize_with { Group.where(name: name).first_or_initialize }
  end

  factory :source do
    name "citeulike"
    title "CiteULike"
    active true

    group

    trait(:datacite_related) do
      name "datacite_related"
      title "DataCite Related"
    end

    trait(:datacite_github) do
      name "datacite_github"
      title "DataCite Github"
    end

    trait(:datacite_orcid) do
      name "datacite_orcid"
      title "DataCite ORCID"
    end

    trait(:datacite_datacentre) do
      name "datacite_datacentre"
      title "DataCite Data Centres"
    end

    trait(:mendeley) do
      name "mendeley"
      title "Mendeley"
    end

    trait(:facebook) do
      name "facebook"
      title "Facebook"
    end

    trait(:github) do
      name "github"
      title "GitHub"
    end

    trait(:counter_html) do
      name "counter_html"
      title "Counter Views"
    end

    trait(:counter_pdf) do
      name "counter_pdf"
      title "Counter Downloads"
    end

    trait(:pmc_html) do
      name "pmc_html"
      title "PubMed Central View Stats"
    end

    trait(:pmc_pdf) do
      name "pmc_pdf"
      title "PubMed Central Download Stats"
    end

    trait(:crossref) do
      name "crossref"
      title "CrossRef"
    end

    trait(:twitter) do
      name "twitter"
      title "Twitter"
    end

    factory :source_with_changes do
      after(:create) do |source|
        FactoryGirl.create_list(:change, 5, source: source, created_at: Time.zone.now - 1.hour)
      end
    end

    initialize_with { Source.where(name: name).first_or_initialize }
  end

  factory :citeulike, aliases: [:agent], class: Citeulike do
    type "Citeulike"
    name "citeulike"
    title "CiteULike"
    state_event "activate"

    cached_at { Time.zone.now - 10.minutes }

    group

    factory :agent_with_api_responses do
      after(:create) do |agent|
        FactoryGirl.create_list(:api_response, 5, agent: agent, created_at: Time.zone.now - 1.hour)
      end
    end

    initialize_with { Citeulike.where(name: name).first_or_initialize }
  end

  factory :copernicus, class: Copernicus do
    type "Copernicus"
    name "copernicus"
    title "Copernicus"
    state_event "activate"
    url_private "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:%{doi}"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Copernicus.where(name: name).first_or_initialize }
  end

  factory :crossref, class: CrossRef do
    type "CrossRef"
    name "crossref"
    title "CrossRef"
    state_event "activate"
    openurl_username "openurl_username"

    group

    initialize_with { CrossRef.where(name: name).first_or_initialize }
  end

  factory :nature, class: Nature do
    type "Nature"
    name "nature"
    title "Nature"
    state_event "activate"

    group

    initialize_with { Nature.where(name: name).first_or_initialize }
  end

  factory :github, class: Github do
    type "Github"
    name "github"
    title "Github"
    personal_access_token "EXAMPLE"

    group

    initialize_with { Github.where(name: name).first_or_initialize }
  end

  factory :bitbucket, class: Bitbucket do
    type "Bitbucket"
    name "bitbucket"
    title "Bitbucket"

    group

    initialize_with { Bitbucket.where(name: name).first_or_initialize }
  end

  factory :openedition, class: Openedition do
    type "Openedition"
    name "openedition"
    title "OpenEdition"
    state_event "activate"

    group

    initialize_with { Openedition.where(name: name).first_or_initialize }
  end

  factory :pmc, class: Pmc do
    type "Pmc"
    name "pmc"
    title "PubMed Central Usage Stats"
    state_event "activate"

    group

    after(:create) do |agent|
      FactoryGirl.create(:publisher_option_for_pmc, agent: agent)
    end

    factory :pmc_with_multiple_journals do
      after(:create) do |agent|
        FactoryGirl.create(:publisher_option_for_pmc, agent: agent, journals: "plosbiol plosone")
      end
    end

    initialize_with { Pmc.where(name: name).first_or_initialize }
  end

  factory :pub_med, class: PubMed do
    type "PubMed"
    name "pub_med"
    title "PubMed"
    state_event "activate"

    group

    initialize_with { PubMed.where(name: name).first_or_initialize }
  end

  factory :europe_pmc, class: EuropePmc do
    type "EuropePmc"
    name "pmc_europe"
    title "PMC Europe Citations"
    state_event "activate"

    group

    initialize_with { EuropePmc.where(name: name).first_or_initialize }
  end

  factory :europe_pmc_data, class: EuropePmcData do
    type "EuropePmcData"
    name "pmc_europe_data"
    title "PMC Europe Database Citations"
    state_event "activate"

    group

    initialize_with { EuropePmcData.where(name: name).first_or_initialize }
  end

  factory :europe_pmc_fulltext_data, class: EuropePmcFulltextData do
    type "EuropePmcFulltextData"
    name "pmc_europe_fulltext_data"
    title "PMC Europe Fulltext Data Search"
    state_event "activate"

    group

    initialize_with { EuropePmcFulltextData.where(name: name).first_or_initialize }
  end

  factory :europe_pmc_fulltext, class: EuropePmcFulltext do
    type "EuropePmcFulltext"
    name "europe_pmc_fulltext"
    title "Europe PMC Fulltext Search"
    state_event "activate"

    group

    initialize_with { EuropePmcFulltext.where(name: name).first_or_initialize }
  end

  factory :nature_opensearch, class: NatureOpensearch do
    type "NatureOpensearch"
    name "nature_opensearch"
    title "Nature.com OpenSearch"
    state_event "activate"

    group

    initialize_with { NatureOpensearch.where(name: name).first_or_initialize }
  end

  factory :researchblogging, class: Researchblogging do
    type "Researchblogging"
    name "researchblogging"
    title "Research Blogging"
    state_event "activate"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Researchblogging.where(name: name).first_or_initialize }
  end

  factory :science_seeker, class: ScienceSeeker do
    type "ScienceSeeker"
    name "scienceseeker"
    title "ScienceSeeker"
    state_event "activate"

    group

    initialize_with { ScienceSeeker.where(name: name).first_or_initialize }
  end

  factory :wordpress, class: Wordpress do
    type "Wordpress"
    name "wordpress"
    title "Wordpress.com"
    state_event "activate"

    group

    initialize_with { Wordpress.where(name: name).first_or_initialize }
  end

  factory :reddit, class: Reddit do
    type "Reddit"
    name "reddit"
    title "Reddit"
    state_event "activate"

    group

    initialize_with { Reddit.where(name: name).first_or_initialize }
  end

  factory :twitter_search, class: TwitterSearch do
    type "TwitterSearch"
    name "twitter_search"
    title "Twitter"
    state_event "activate"
    api_key "EXAMPLE"
    api_secret "EXAMPLE"
    access_token "EXAMPLE"

    group

    initialize_with { TwitterSearch.where(name: name).first_or_initialize }
  end

  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    title "Wikipedia"
    state_event "activate"
    languages "en"

    group

    initialize_with { Wikipedia.where(name: name).first_or_initialize }
  end

  factory :mendeley, class: Mendeley do
    type "Mendeley"
    name "mendeley"
    title "Mendeley"
    state_event "activate"
    client_id ENV['MENDELEY_CLIENT_ID']
    client_secret ENV['MENDELEY_CLIENT_SECRET']
    expires_at { Time.zone.now + 1.hour }

    group

    initialize_with { Mendeley.where(name: name).first_or_initialize }
  end

  factory :facebook, class: Facebook do
    type "Facebook"
    name "facebook"
    title "Facebook"
    client_id ENV['FACEBOOK_CLIENT_ID']
    client_secret ENV['FACEBOOK_CLIENT_SECRET']

    group

    initialize_with { Facebook.where(name: name).first_or_initialize }
  end

  factory :scopus, class: Scopus do
    type "Scopus"
    name "scopus"
    title "Scopus"
    api_key "EXAMPLE"
    insttoken "EXAMPLE"

    group

    initialize_with { Scopus.where(name: name).first_or_initialize }
  end

  factory :counter, class: Counter do
    type "Counter"
    name "counter"
    title "Counter"
    state_event "activate"
    url_private "http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}"

    group

    initialize_with { Counter.where(name: name).first_or_initialize }
  end

  factory :dataone_counter, class: DataoneCounter do
    type "DataoneCounter"
    name "dataone_counter"
    title "DataONE Counter"
    state_event "activate"

    group

    initialize_with { DataoneCounter.where(name: name).first_or_initialize }
  end

  factory :dataone_usage, class: DataoneUsage do
    type "DataoneUsage"
    name "dataone_usage"
    title "DataONE Usage"
    state_event "activate"

    group

    initialize_with { DataoneUsage.where(name: name).first_or_initialize }
  end

  factory :f1000, class: F1000 do
    type "F1000"
    name "f1000"
    title "F1000Prime"
    state_event "activate"
    url_private "http://example.com/intermediate.xml"

    group

    initialize_with { F1000.where(name: name).first_or_initialize }
  end

  factory :figshare, class: Figshare do
    type "Figshare"
    name "figshare"
    title "Figshare"
    state_event "activate"
    url_private "http://api.figshare.com/v1/publishers/search_for?doi=%{doi}"

    group

    initialize_with { Figshare.where(name: name).first_or_initialize }
  end

  factory :plos_comments, class: PlosComments do
    type "PlosComments"
    name "plos_comments"
    title "PLOS Comments"
    state_event "activate"
    url_private "http://api.plosjournals.org/v1/articles/%{doi}?comments="

    group

    initialize_with { PlosComments.where(name: name).first_or_initialize }
  end

  factory :plos_fulltext, class: PlosFulltext do
    type "PlosFulltext"
    name "plos_fulltext"
    title "PLOS Fulltext Search"
    state_event "activate"

    group

    initialize_with { PlosFulltext.where(name: name).first_or_initialize }
  end

  factory :ads, class: Ads do
    type "Ads"
    name "ads"
    title "ADS"
    state_event "activate"
    access_token "EXAMPLE"

    group

    initialize_with { Ads.where(name: name).first_or_initialize }
  end

  factory :ads_fulltext, class: AdsFulltext do
    type "AdsFulltext"
    name "ads_fulltext"
    title "ADS Fulltext"
    state_event "activate"
    access_token "EXAMPLE"

    group

    initialize_with { AdsFulltext.where(name: name).first_or_initialize }
  end

  factory :bmc_fulltext, class: BmcFulltext do
    type "BmcFulltext"
    name "bmc_fulltext"
    title "BMC Fulltext Search"
    state_event "activate"

    group

    initialize_with { BmcFulltext.where(name: name).first_or_initialize }
  end

  factory :twitter, class: Twitter do
    type "Twitter"
    name "twitter"
    title "Twitter"
    state_event "activate"
    url_private "http://example.org?doi=%{doi}"

    group

    initialize_with { Twitter.where(name: name).first_or_initialize }
  end

  factory :wos, class: Wos do
    type "Wos"
    name "wos"
    title "Web of Science"
    state_event "activate"
    url_private "https://ws.isiknowledge.com:80/cps/xrpc"

    group

    initialize_with { Wos.where(name: name).first_or_initialize }
  end

  factory :relative_metric, class: RelativeMetric do
    type "RelativeMetric"
    name "relative_metric"
    title "Relative Metric"
    state_event "activate"
    url_private "http://example.org?doi=%{doi}"

    group

    initialize_with { RelativeMetric.where(name: name).first_or_initialize }
  end

  factory :article_coverage, class: ArticleCoverage do
    type "ArticleCoverage"
    name "article_coverage"
    title "Article Coverage"
    state_event "activate"
    url_private "http://mediacuration.plos.org/api/v1?doi=%{doi}&state=all"

    group

    initialize_with { ArticleCoverage.where(name: name).first_or_initialize }
  end

  factory :article_coverage_curated, class: ArticleCoverageCurated do
    type "ArticleCoverageCurated"
    name "article_coverage_curated"
    title "Article Coverage Curated"
    state_event "activate"
    url_private "http://mediacuration.plos.org/api/v1?doi=%{doi}"

    group

    initialize_with { ArticleCoverageCurated.where(name: name).first_or_initialize }
  end

  factory :orcid, class: Orcid do
    type "Orcid"
    name "orcid"
    title "ORCID"
    state_event "activate"

    group

    initialize_with { Orcid.where(name: name).first_or_initialize }
  end

  factory :plos_import, class: PlosImport do
    type "PlosImport"
    name "plos_import"
    title "PLOS Import"
    state_event "activate"

    group

    initialize_with { PlosImport.where(name: name).first_or_initialize }
  end

  factory :crossref_import, class: CrossrefImport do
    type "CrossrefImport"
    name "crossref_import"
    title "Crossref Import"
    only_publishers true
    state_event "activate"

    group

    initialize_with { CrossrefImport.where(name: name).first_or_initialize }
  end

  factory :crossref_orcid, class: CrossrefOrcid do
    type "CrossrefOrcid"
    name "crossref_orcid"
    title "Crossref ORCID"
    state_event "activate"

    group

    initialize_with { CrossrefOrcid.where(name: name).first_or_initialize }
  end

  factory :crossref_publisher, class: CrossrefPublisher do
    type "CrossrefPublisher"
    name "crossref_publisher"
    title "Crossref Publisher"
    state_event "activate"

    group

    initialize_with { CrossrefPublisher.where(name: name).first_or_initialize }
  end

  factory :datacite_import, class: DataciteImport do
    type "DataciteImport"
    name "datacite_import"
    title "Datacite (Import)"
    state_event "activate"
    only_publishers true

    group

    initialize_with { DataciteImport.where(name: name).first_or_initialize }
  end

  factory :datacite_related, class: DataciteRelated do
    type "DataciteRelated"
    name "datacite_related"
    title "Datacite (RelatedIdentifier)"
    state_event "activate"

    group

    initialize_with { DataciteRelated.where(name: name).first_or_initialize }
  end

  factory :datacite_crossref, class: DataciteCrossref do
    type "DataciteCrossref"
    name "datacite_crossref"
    title "Datacite (Crossref)"
    state_event "activate"

    group

    initialize_with { DataciteCrossref.where(name: name).first_or_initialize }
  end

  factory :datacite_orcid, class: DataciteOrcid do
    type "DataciteOrcid"
    name "datacite_orcid"
    title "Datacite ORCID"
    state_event "activate"

    group

    initialize_with { DataciteOrcid.where(name: name).first_or_initialize }
  end

  factory :datacite_datacentre, class: DataciteDatacentre do
    type "DataciteDatacentre"
    name "datacite_datacentre"
    title "Datacite Datacentre"
    state_event "activate"

    group

    initialize_with { DataciteDatacentre.where(name: name).first_or_initialize }
  end

  factory :datacite_github, class: DataciteGithub do
    type "DataciteGithub"
    name "datacite_github"
    title "Datacite Github"
    state_event "activate"
    personal_access_token "EXAMPLE"

    group

    initialize_with { DataciteGithub.where(name: name).first_or_initialize }
  end

  factory :dataone_import, class: DataoneImport do
    type "DataoneImport"
    name "dataone_import"
    title "DataONE Import"
    state_event "activate"

    group

    initialize_with { DataoneImport.where(name: name).first_or_initialize }
  end

  factory :lagotto_registration_agency, class: LagottoRegistrationAgency do
    type "LagottoRegistrationAgency"
    name "lagotto_registration_agency"
    title "Lagotto (Registration Agency)"
    url_private "http://10.2.2.6/api/deposits?"
    registration_agency_id "crossref"
    state_event "activate"

    group

    initialize_with { LagottoRegistrationAgency.where(name: name).first_or_initialize }
  end
end
