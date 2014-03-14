# encoding: UTF-8

FactoryGirl.define do

  factory :group do
    name 'saved'
    display_name 'Saved'

    initialize_with { Group.find_or_create_by_name(name) }
  end

  factory :delayed_job do
    queue 'citeulike-queue'

    initialize_with { DelayedJob.find_or_create_by_queue(queue) }
  end

  factory :report do
    name 'error_report'
    display_name 'Error Report'
    description 'Reports error summary'

    factory :error_report_with_admin_user do
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :status_report_with_admin_user do
      name 'status_report'
      display_name 'Status Report'
      description 'Reports application status'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :article_statistics_report_with_admin_user do
      name 'article_statistics_report'
      display_name 'Article Statistics Report'
      description 'Generates CSV file with ALM for all articles'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :disabled_source_report_with_admin_user do
      name 'disabled_source_report'
      display_name 'Disabled Source Report'
      description 'Reports when a source has been disabled'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :stale_source_report_with_admin_user do
      name 'stale_source_report'
      display_name 'Stale Source Report'
      description 'Reports when a source has not been updated'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :missing_workers_report_with_admin_user do
      name 'missing_workers_report'
      display_name 'Missing Workers Report'
      description 'Reports when workers are not running'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end
  end

  factory :retrieval_history do
    retrieved_at { Time.zone.today - 1.month }
    event_count { retrieval_status.event_count }
    status { event_count > 0 ? "SUCCESS" : "ERROR" }
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
    name "crossref"
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
    name "pubmed"
    display_name "PubMed"
    state_event "activate"

    group

    initialize_with { PubMed.find_or_create_by_name(name) }
  end

  factory :pmc_europe, class: PmcEurope do
    type "PmcEurope"
    name "pmceurope"
    display_name "PMC Europe Citations"
    state_event "activate"

    group

    initialize_with { PmcEurope.find_or_create_by_name(name) }
  end

    factory :pmc_europe_data, class: PmcEuropeData do
    type "PmcEuropeData"
    name "pmceuropedata"
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
    access_token "TOKEN"

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
    access_token "EXAMPLE"

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

  factory :alert do
    exception "An exception"
    class_name "Net::HTTPRequestTimeOut"
    message "The request timed out."
    trace "backtrace"
    request "A request"
    user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"
    target_url "http://127.0.0.1/sources/x"
    remote_ip "127.0.0.1"
    status 408
    content_type "text/html"
  end

  factory :api_request do
    db_duration 100
    view_duration 700
    api_key "67890"
    info "history"
    source nil
    ids "10.1371%2Fjournal.pone.000001"

    trait(:local) { api_key "12345" }
  end

  factory :api_response do
    duration 200
    event_count 10
    previous_count 5
    update_interval 7
    unresolved 1
    source_id 1
    retrieval_history_id 1
  end

  factory :review do
    name "ArticleNotUpdatedError"
    message "Found 0 article not updated errors in 29,899 API responses, taking 29.899 ms"
    input 10
    created_at { Time.zone.now }
  end

  factory :article_not_updated_error, aliases: [:filter], class: ArticleNotUpdatedError do
    type "ArticleNotUpdatedError"
    name "ArticleNotUpdatedError"
    display_name "article not updated error"
    active true

    initialize_with { ArticleNotUpdatedError.find_or_create_by_name(name) }
  end

  factory :decreasing_event_count_error, class: EventCountDecreasingError do
    type "EventCountDecreasingError"
    name "EventCountDecreasingError"
    display_name "decreasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountDecreasingError.find_or_create_by_name(name) }
  end

  factory :increasing_event_count_error, class: EventCountIncreasingTooFastError do
    type "EventCountIncreasingTooFastError"
    name "EventCountIncreasingTooFastError"
    display_name "increasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountIncreasingTooFastError.find_or_create_by_name(name) }
  end

  factory :api_too_slow_error, class: ApiResponseTooSlowError do
    type "ApiResponseTooSlowError"
    name "ApiResponseTooSlowError"
    display_name "API too slow error"
    active true

    initialize_with { ApiResponseTooSlowError.find_or_create_by_name(name) }
  end

  factory :source_not_updated_error, class: SourceNotUpdatedError do
    type "SourceNotUpdatedError"
    name "SourceNotUpdatedError"
    display_name "source not updated error"
    active true

    initialize_with { SourceNotUpdatedError.find_or_create_by_name(name) }
  end
end