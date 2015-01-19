FactoryGirl.define do

  factory :work do
    sequence(:doi) { |n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) { |n| "1897483#{n}" }
    sequence(:pmcid) { |n| "256885#{n}" }
    sequence(:wos) { |n| "00023796690000#{n}" }
    sequence(:scp) { |n| "3384533872#{n}" }
    sequence(:canonical_url) { |n| "http://www.plosone.org/article/info:doi/10.1371/journal.pone.00000#{n}" }
    mendeley_uuid "46cb51a0-6d08-11df-afb8-0026b95d30b2"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    year { Time.zone.now.to_date.year - 1 }
    month { Time.zone.now.to_date.month }
    day { Time.zone.now.to_date.day }
    publisher_id 340

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:missing_mendeley) { mendeley_uuid nil }

    factory :work_with_events do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, work: work)
      end
    end

    factory :work_with_events_and_alerts do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, work: work)
        FactoryGirl.create(:alert, :work => work)
      end
    end

    factory :stale_works do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :stale, work: work)
      end
    end

    factory :queued_works do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :queued, work: work)
      end
    end

    factory :refreshed_works do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :refreshed, work: work)
      end
    end

    factory :work_for_feed do
      date = Time.zone.now - 1.day
      year { date.year }
      month { date.month }
      day { date.day }
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :refreshed, retrieved_at: date, work: work)
      end
    end

    factory :work_published_today do
      year { Time.zone.now.year }
      retrieval_statuses { |work| [work.association(:retrieval_status, retrieved_at: Time.zone.now)] }
    end

    factory :work_with_errors do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_errors, work: work)
      end
    end

    factory :work_with_private_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_private, work: work)
      end
    end

    factory :work_with_crossref_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_crossref, work: work)
      end
    end

    factory :work_with_pubmed_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_pubmed, work: work)
      end
    end

    factory :work_with_mendeley_events do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_mendeley, work: work)
      end
    end

    factory :work_with_nature_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_nature, work: work)
      end
    end

    factory :work_with_researchblogging_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_researchblogging, work: work)
      end
    end

    factory :work_with_wos_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_wos, work: work)
      end
    end

    factory :work_with_counter_citations do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_counter, work: work)
      end
    end

    factory :work_with_tweets do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_twitter_search, work: work)
      end
    end
  end

  factory :retrieval_status do
    event_count 50
    event_metrics do
      { :pdf => nil,
        :html => nil,
        :shares => 50,
        :groups => nil,
        :comments => nil,
        :likes => nil,
        :citations => nil,
        :total => 50 }
    end
    retrieved_at { Time.zone.now - 1.month }
    sequence(:scheduled_at) { |n| Time.zone.now - 1.day + n.minutes }

    association :work
    association :source, factory: :citeulike

    trait(:missing_mendeley) do
      association :work, :missing_mendeley, factory: :work
      association :source, factory: :mendeley
    end
    trait(:stale) { scheduled_at 1.month.ago }
    trait(:queued) { queued_at 1.hour.ago }
    trait(:refreshed) { scheduled_at 1.month.from_now }
    trait(:staleness) { association :source, factory: :citeulike }
    trait(:with_errors) { event_count 0 }
    trait(:with_private) { association :source, private: true }
    trait(:with_crossref) { association :source, factory: :crossref }
    trait(:with_mendeley) { association :source, factory: :mendeley }
    trait(:with_pubmed) { association :source, factory: :pub_med }
    trait(:with_nature) { association :source, factory: :nature }
    trait(:with_wos) { association :source, factory: :wos }
    trait(:with_researchblogging) { association :source, factory: :researchblogging }
    trait(:with_scienceseeker) { association :source, factory: :scienceseeker }
    trait(:with_wikipedia) { association :source, factory: :wikipedia }
    trait(:with_counter) { association :source, factory: :counter }
    trait(:with_twitter_search) { association :source, factory: :twitter_search }
    trait(:with_work_published_today) { association :work, factory: :work_published_today }
    trait(:with_counter_and_work_published_today) do
      association :work, factory: :work_published_today
      association :source, factory: :counter
    end
    trait(:with_crossref_and_work_published_today) do
      association :work, factory: :work_published_today
      association :source, factory: :crossref
    end

    trait(:with_crossref_histories) do
      before(:create) do |retrieval_status|
        FactoryGirl.create_list(:retrieval_history, 20, retrieval_status: retrieval_status,
                                                        work: retrieval_status.work,
                                                        source: retrieval_status.source)
      end
    end

    initialize_with { RetrievalStatus.where(work_id: work.id, source_id: source.id).first_or_initialize }
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

    factory :work_statistics_report_with_admin_user do
      name 'work_statistics_report'
      display_name 'Article Statistics Report'
      description 'Generates CSV file with ALM for all works'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :fatal_error_report_with_admin_user do
      name 'fatal_error_report'
      display_name 'Fatal Error Report'
      description 'Reports when a fatal error has occured'
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
    sequence(:retrieved_at) do |n|
      Time.zone.now - n.weeks
    end
    sequence(:event_count) { |n| 1000 - 10 * n }

    retrieval_status
    work
    source
  end

  factory :alert do
    exception "An exception"
    class_name "Net::HTTPRequestTimeOut"
    message "The request timed out."
    level 2
    trace "backtrace"
    request "A request"
    user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"
    target_url "http://127.0.0.1/sources/x"
    remote_ip "127.0.0.1"
    status 408
    content_type "text/html"

    factory :alert_with_source do
      source
    end
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
  end

  factory :review do
    name "WorkNotUpdatedError"
    message "Found 0 work not updated errors in 29,899 API responses, taking 29.899 ms"
    input 10
    created_at { Time.zone.now }
  end

  factory :user do
    sequence(:email) { |n| "joe#{n}@example.com" }
    sequence(:name) { |n| "Joe Smith#{n}" }
    password "joesmith"
    sequence(:authentication_token) { |n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    provider "persona"
    sequence(:uid) { |n| "joe#{n}@example.com" }
    publisher_id 340

    factory :admin_user do
      role "admin"
      authentication_token "12345"
    end

    initialize_with { User.where(authentication_token: authentication_token).first_or_initialize }
  end

  factory :publisher do
    name "340"
    member_id 340
    title 'Public Library of Science (PLoS)'
    other_names ["Public Library of Science", "Public Library of Science (PLoS)"]
    prefixes ["10.1371"]
    service "crossref"

    initialize_with { Publisher.where(member_id: member_id).first_or_initialize }
  end

  factory :publisher_option do
    id 1
    source_id 1
    publisher_id 340
    username "username"
    password "password"

    publisher

    initialize_with { PublisherOption.where(id: id).first_or_initialize }

    factory :publisher_option_for_pmc do
      journals "ajrccm"
    end
  end

  factory :html_ratio_too_high_error, class: HtmlRatioTooHighError do
    type "HtmlRatioTooHighError"
    name "HtmlRatioTooHighError"
    display_name "html ratio too high error"
    active true

    initialize_with { HtmlRatioTooHighError.where(name: name).first_or_initialize }
  end

  factory :work_not_updated_error, aliases: [:filter], class: WorkNotUpdatedError do
    type "WorkNotUpdatedError"
    name "WorkNotUpdatedError"
    display_name "work not updated error"
    active true

    initialize_with { WorkNotUpdatedError.where(name: name).first_or_initialize }
  end

  factory :decreasing_event_count_error, class: EventCountDecreasingError do
    type "EventCountDecreasingError"
    name "EventCountDecreasingError"
    display_name "decreasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountDecreasingError.where(name: name).first_or_initialize }
  end

  factory :increasing_event_count_error, class: EventCountIncreasingTooFastError do
    type "EventCountIncreasingTooFastError"
    name "EventCountIncreasingTooFastError"
    display_name "increasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountIncreasingTooFastError.where(name: name).first_or_initialize }
  end

  factory :api_too_slow_error, class: ApiResponseTooSlowError do
    type "ApiResponseTooSlowError"
    name "ApiResponseTooSlowError"
    display_name "API too slow error"
    active true

    initialize_with { ApiResponseTooSlowError.where(name: name).first_or_initialize }
  end

  factory :source_not_updated_error, class: SourceNotUpdatedError do
    type "SourceNotUpdatedError"
    name "SourceNotUpdatedError"
    display_name "source not updated error"
    active true

    initialize_with { SourceNotUpdatedError.where(name: name).first_or_initialize }
  end

  factory :status do
    works_count 5
    responses_count 5
    requests_count 5
    current_version "3.13"
  end
end
