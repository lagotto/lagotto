# encoding: UTF-8

FactoryGirl.define do

  factory :group do
    name 'saved'
    display_name 'Saved'

    initialize_with { Group.find_or_create_by_name(name) }
  end

  factory :citeulike, aliases: [:source], class: Citeulike do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    state_event "activate"

    cached_at { Time.zone.now - 10.minutes }

    group

    initialize_with { Citeulike.find_or_create_by_name(name) }

    factory :source_with_api_responses do
      ignore do
        api_responses_count 5
      end

      after(:create) do |source, evaluator|
        FactoryGirl.create_list(:api_response, evaluator.api_responses_count, source: source)
      end
    end
  end

  factory :copernicus, class: Copernicus do
    type "Copernicus"
    name "copernicus"
    display_name "Copernicus"
    state_event "activate"
    url "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:%{doi}"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Copernicus.find_or_create_by_name(name) }
  end

  factory :cross_ref, class: CrossRef do
    type "CrossRef"
    name "cross_ref"
    display_name "CrossRef"
    state_event "activate"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { CrossRef.find_or_create_by_name(name) }
  end

  factory :nature, class: Nature do
    type "Nature"
    name "nature"
    display_name "Nature"
    state_event "activate"

    group

    initialize_with { Nature.find_or_create_by_name(name) }
  end

  factory :openedition, class: Openedition do
    type "Openedition"
    name "openedition"
    display_name "OpenEdition"
    state_event "activate"

    group

    initialize_with { Openedition.find_or_create_by_name(name) }
  end

  factory :pmc, class: Pmc do
    type "Pmc"
    name "pmc"
    display_name "PubMed Central Usage Stats"
    state_event "activate"
    url "http://127.0.0.1:5984/pmc_usage_stats_test/"
    journals "ajrccm"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Pmc.find_or_create_by_name(name) }
  end

  factory :pub_med, class: PubMed do
    type "PubMed"
    name "pub_med"
    display_name "PubMed"
    state_event "activate"

    group

    initialize_with { PubMed.find_or_create_by_name(name) }
  end

  factory :pmc_europe, class: PmcEurope do
    type "PmcEurope"
    name "pmc_europe"
    display_name "PMC Europe Citations"
    state_event "activate"

    group

    initialize_with { PmcEurope.find_or_create_by_name(name) }
  end

    factory :pmc_europe_data, class: PmcEuropeData do
    type "PmcEuropeData"
    name "pmc_europe_data"
    display_name "PMC Europe Database Citations"
    state_event "activate"

    group

    initialize_with { PmcEuropeData.find_or_create_by_name(name) }
  end

  factory :researchblogging, class: Researchblogging do
    type "Researchblogging"
    name "researchblogging"
    display_name "Research Blogging"
    state_event "activate"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Researchblogging.find_or_create_by_name(name) }
  end

  factory :science_seeker, class: ScienceSeeker do
    type "ScienceSeeker"
    name "scienceseeker"
    display_name "ScienceSeeker"
    state_event "activate"

    group

    initialize_with { ScienceSeeker.find_or_create_by_name(name) }
  end

  factory :datacite, class: Datacite do
    type "Datacite"
    name "datacite"
    display_name "DataCite"
    state_event "activate"

    group

    initialize_with { Datacite.find_or_create_by_name(name) }
  end

  factory :wordpress, class: Wordpress do
    type "Wordpress"
    name "wordpress"
    display_name "Wordpress.com"
    state_event "activate"

    group

    initialize_with { Wordpress.find_or_create_by_name(name) }
  end

  factory :reddit, class: Reddit do
    type "Reddit"
    name "reddit"
    display_name "Reddit"
    state_event "activate"

    group

    initialize_with { Reddit.find_or_create_by_name(name) }
  end

  factory :twitter_search, class: TwitterSearch do
    type "TwitterSearch"
    name "twitter_search"
    display_name "Twitter"
    state_event "activate"
    api_key "EXAMPLE"
    api_secret "EXAMPLE"
    access_token "EXAMPLE"

    group

    initialize_with { TwitterSearch.find_or_create_by_name(name) }
  end

  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    display_name "Wikipedia"
    state_event "activate"
    languages "en"

    group

    initialize_with { Wikipedia.find_or_create_by_name(name) }
  end

  factory :mendeley, class: Mendeley do
    type "Mendeley"
    name "mendeley"
    display_name "Mendeley"
    state_event "activate"
    client_id "EXAMPLE"
    secret "EXAMPLE"
    access_token "EXAMPLE"
    expires_at { Time.zone.now + 1.hour }

    group

    initialize_with { Mendeley.find_or_create_by_name(name) }
  end

  factory :facebook, class: Facebook do
    type "Facebook"
    name "facebook"
    display_name "Facebook"
    state_event "activate"
    access_token "EXAMPLE"

    group

    initialize_with { Facebook.find_or_create_by_name(name) }
  end

  factory :scopus, class: Scopus do
    type "Scopus"
    name "scopus"
    display_name "Scopus"
    api_key "EXAMPLE"
    insttoken "EXAMPLE"

    group

    initialize_with { Scopus.find_or_create_by_name(name) }
  end

  factory :counter, class: Counter do
    type "Counter"
    name "counter"
    display_name "Counter"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { Counter.find_or_create_by_name(name) }
  end

  factory :biod, class: Biod do
    type "Biod"
    name "biod"
    display_name "Biod"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { Counter.find_or_create_by_name(name) }
  end

  factory :f1000, class: F1000 do
    type "F1000"
    name "f1000"
    display_name "F1000Prime"
    state_event "activate"
    url "http://example.org/example.xml"
    filename "example.xml"

    group

    initialize_with { F1000.find_or_create_by_name(name) }
  end

  factory :figshare, class: Figshare do
    type "Figshare"
    name "figshare"
    display_name "Figshare"
    state_event "activate"
    url "http://api.figshare.com/v1/publishers/search_for?doi=%{doi}"

    group

    initialize_with { Figshare.find_or_create_by_name(name) }
  end

  factory :plos_comments, class: PlosComments do
    type "PlosComments"
    name "plos_comments"
    display_name "PLOS Comments"
    state_event "activate"
    url "http://example.org?doi={doi}"

    group

    initialize_with { PlosComments.find_or_create_by_name(name) }
  end

  factory :twitter, class: Twitter do
    type "Twitter"
    name "twitter"
    display_name "Twitter"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { Twitter.find_or_create_by_name(name) }
  end

  factory :wos, class: Wos do
    type "Wos"
    name "wos"
    display_name "Web of Science"
    state_event "activate"
    private true
    url "https://ws.isiknowledge.com:80/cps/xrpc"

    group

    initialize_with { Wos.find_or_create_by_name(name) }
  end

  factory :relative_metric, class: RelativeMetric do
    type "RelativeMetric"
    name "relative_metric"
    display_name "Relative Metric"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { RelativeMetric.find_or_create_by_name(name) }
  end

  factory :article_coverage, class: ArticleCoverage do
    type "ArticleCoverage"
    name "article_coverage"
    display_name "Article Coverage"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { ArticleCoverage.find_or_create_by_name(name) }
  end

  factory :article_coverage_curated, class: ArticleCoverageCurated do
    type "ArticleCoverageCurated"
    name "article_coverage_curated"
    display_name "Article Coverage Curated"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { ArticleCoverageCurated.find_or_create_by_name(name) }
  end
end