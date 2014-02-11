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

    factory :article_published_today do
      published_on { Time.zone.today }
      retrieval_statuses { |article| [article.association(:retrieval_status, retrieved_at: Time.zone.today)] }
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
    trait(:with_article_published_today) { association :article, factory: :article_published_today }

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

  factory :user do
    sequence(:username) {|n| "joesmith#{n}" }
    sequence(:name) {|n| "Joe Smith#{n}" }
    sequence(:email) {|n| "joe#{n}@example.com" }
    password "joesmith"
    sequence(:authentication_token) {|n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    provider "persona"
    uid "12345"

    factory :admin_user do
      role "admin"
      authentication_token "12345"
    end
  end
end