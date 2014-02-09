# encoding: UTF-8

FactoryGirl.define do

  factory :article do
    sequence(:doi) {|n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) {|n| "1897483#{n}" }
    pmcid 2568856
    mendeley_uuid "46cb51a0-6d08-11df-afb8-0026b95d30b2"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on { Time.zone.today - 1.year }

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:missing_mendeley) { mendeley_uuid nil }
    trait(:unpublished) { published_on { Time.zone.today + 1.week } }

    factory :article_with_events do
      retrieval_statuses { |article| [article.association(:retrieval_status)] }
    end

    factory :article_with_events_and_alerts do
      retrieval_statuses { |article| [article.association(:retrieval_status)] }
      alerts { |article| [article.association(:alert)] }
    end

    factory :article_for_feed do
      published_on { Time.zone.today - 1.day }
      retrieval_statuses { |article| [article.association(:retrieval_status, retrieved_at: Time.zone.today - 1.day)] }
    end

    factory :article_with_errors do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_errors)] }
    end

    factory :article_with_private_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_private)] }
    end

    factory :article_with_crossref_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_crossref)] }
    end

    factory :article_with_pubmed_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_pubmed)] }
    end

    factory :article_with_mendeley_events do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_mendeley)] }
    end

    factory :article_with_nature_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_pubmed)] }
    end

    factory :article_with_researchblogging_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_researchblogging)] }
    end

    factory :article_with_wos_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_wos)] }
    end

    factory :article_with_counter_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_counter)] }
    end

    factory :article_with_tweets do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_twitter_search)] }
    end
  end

  factory :retrieval_status do
    event_count 50
    retrieved_at { Time.zone.now - 1.month }
    sequence(:scheduled_at) {|n| Time.zone.now - 1.day + n.minutes }

    association :article
    association :source, factory: :citeulike

    trait(:unpublished) { association :article, :unpublished, factory: :article }
    trait(:missing_mendeley) do
      association :article, :missing_mendeley, factory: :article
      association :source, factory: :mendeley
    end
    trait(:staleness) { association :source, factory: :citeulike }
    trait(:with_errors) { event_count 0 }
    trait(:with_private) { association :source, private: true }
    trait(:with_crossref) { association :source, factory: :cross_ref }
    trait(:with_mendeley) { association :source, factory: :mendeley }
    trait(:with_pubmed) { association :source, factory: :pub_med }
    trait(:with_nature) { association :source, factory: :nature }
    trait(:with_wos) { association :source, factory: :wos }
    trait(:with_researchblogging) { association :source, factory: :researchblogging }
    trait(:with_scienceseeker) { association :source, factory: :scienceseeker }
    trait(:with_wikipedia) { association :source, factory: :wikipedia }
    trait(:with_counter) { association :source, factory: :counter }
    trait(:with_twitter_search) { association :source, factory: :twitter_search }

    before(:create) do |retrieval_status|
      FactoryGirl.create(:retrieval_history,
                          retrieved_at: Time.zone.today - 2.years + 1.day,
                          event_count: 50,
                          retrieval_status: retrieval_status,
                          article: retrieval_status.article,
                          source: retrieval_status.source)
    end

    initialize_with { RetrievalStatus.find_or_create_by_article_id_and_source_id(article.id, source.id) }
  end

  factory :counter, class: Counter do
    type "Counter"
    name "counter"
    display_name "Counter"
    state_event "activate"
    url "http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}"

    group

    initialize_with { Counter.find_or_create_by_name(name) }
  end

  factory :f1000, class: F1000 do
    type "F1000"
    name "f1000"
    display_name "F1000Prime"
    state_event "activate"
    url "http://linkout.export.f1000.com.s3.amazonaws.com/linkout/PLOS-intermediate.xml"
    filename "PLOS-intermediate.xml"

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
    url "http://api.plosjournals.org/v1/articles/%{doi}?comments"

    group

    initialize_with { PlosComments.find_or_create_by_name(name) }
  end

  factory :scopus, class: Scopus do
    type "Scopus"
    name "scopus"
    display_name "Scopus"
    state_event "activate"
    live_mode "true"
    username "EXAMPLE"
    salt "EXAMPLE"
    partner_id "EXAMPLE"

    group

    initialize_with { Scopus.find_or_create_by_name(name) }
  end

  factory :twitter, class: Twitter do
    type "Twitter"
    name "twitter"
    display_name "Twitter"
    state_event "activate"
    url "http://rwc-couch01.int.plos.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key=%{doi}"

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
    name "relativemetric"
    display_name "Relative Metric"
    state_event "activate"
    url "http://rwc-couch01.int.plos.org:5984/relative_metrics/_design/relative_metric/_view/average_usage?key=\"%{doi}\""

    group

    initialize_with { RelativeMetric.find_or_create_by_name(name) }
  end

  factory :article_coverage, class: ArticleCoverage do
    type "ArticleCoverage"
    name "articlecoverage"
    display_name "Article Coverage"
    state_event "activate"
    url "http://mediacuration.plos.org/api/v1?doi=%{doi}&state=all"

    group

    initialize_with { ArticleCoverage.find_or_create_by_name(name) }
  end

  factory :article_coverage_curated, class: ArticleCoverageCurated do
    type "ArticleCoverageCurated"
    name "articlecoveragecurated"
    display_name "Article Coverage Curated"
    state_event "activate"
    url "http://mediacuration.plos.org/api/v1?doi=%{doi}"

    group

    initialize_with { ArticleCoverageCurated.find_or_create_by_name(name) }
  end

  factory :user do
    sequence(:username) {|n| "joesmith#{n}" }
    sequence(:name) {|n| "Joe Smith#{n}" }
    sequence(:email) {|n| "joe#{n}@example.com" }
    password "joesmith"
    sequence(:authentication_token) {|n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    role "admin"
    provider "cas"
    uid "12345"

    factory :admin_user do
      role "admin"
      authentication_token "12345"
    end
  end

  factory :html_ratio_too_high_error, class: HtmlRatioTooHighError do
    type "HtmlRatioTooHighError"
    name "HtmlRatioTooHighError"
    display_name "html ratio too high error"
    active true

    initialize_with { HtmlRatioTooHighError.find_or_create_by_name(name) }
  end
end