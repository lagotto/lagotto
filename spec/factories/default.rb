FactoryGirl.define do

  factory :work, aliases: [:related_work] do
    sequence(:doi) { |n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) { |n| "1897483#{n}" }
    sequence(:pmcid) { |n| "256885#{n}" }
    sequence(:wos) { |n| "00023796690000#{n}" }
    sequence(:scp) { |n| "3384533872#{n}" }
    sequence(:ark) { |n| "ark:/13030/m5br8st#{n}" }
    sequence(:canonical_url) { |n| "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.00000#{n}" }
    mendeley_uuid "46cb51a0-6d08-11df-afb8-0026b95d30b2"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    year { Time.zone.now.to_date.year - 1 }
    month { Time.zone.now.to_date.month }
    day { Time.zone.now.to_date.day }
    publisher_id 340
    tracked true
    csl {{}}

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }

    factory :work_with_events do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, work: work, readers: 50, events_url: "http://www.citeulike.org/doi/#{work.doi}", extra: [{ "event" =>{ "link" => { "url" => "http://www.citeulike.org/user/klauso/article/12029653" }, "post_time" => "2013-02-15 15:12:04", "tag" => ["call", "newspecies", "otusjolandae"], "linkout" => { "type" => "DOI", "url" => "http://dx.doi.org/10.1371/journal.pone.0053712" }, "username" => "klauso", "article_id" => "12029653" }, "event_time" => "2013-02-15T15:12:04Z", "event_url" => "http://www.citeulike.org/user/klauso/article/12029653" }] )
        FactoryGirl.create(:retrieval_status, :with_mendeley, work: work, readers: 50, extra: { "title" => "A New Owl Species of the Genus Otus (Aves: Strigidae) from Lombok, Indonesia" } )
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
      year { Time.zone.now.to_date.year }
      month { Time.zone.now.to_date.month }
      day { Time.zone.now.to_date.day - 1 }
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :refreshed, retrieved_at: Time.zone.now - 1.day, work: work)
      end
    end

    factory :work_published_today do
      year { Time.zone.now.to_date.year }
      month { Time.zone.now.to_date.month }
      day { Time.zone.now.to_date.day }
      retrieval_statuses { |work| [work.association(:retrieval_status, retrieved_at: Time.zone.now)] }
    end

    factory :work_published_last_day do
      year { Time.zone.now.to_date.year }
      month { Time.zone.now.to_date.month }
      day { Time.zone.now.to_date.day - 1 }
      retrieval_statuses { |work| [work.association(:retrieval_status, retrieved_at: Time.zone.now - 1.day)] }
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

    factory :work_with_pmc_usage_stats do
      after :create do |work|
        FactoryGirl.create(:retrieval_status, :with_pmc, work: work, readers: 0, pdf: 10, html: 50, total: 60)
      end
    end
  end

  factory :retrieval_status do
    total 50
    readers 50
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
    trait(:with_errors) { total 0 }
    trait(:with_private) { association :source, private: true }
    trait(:with_mendeley) { association :source, factory: :mendeley }
    trait(:with_pubmed) { association :source, factory: :pub_med }
    trait(:with_nature) { association :source, factory: :nature }
    trait(:with_pmc) { association :source, factory: :pmc }
    trait(:with_wos) { association :source, factory: :wos }
    trait(:with_researchblogging) { association :source, factory: :researchblogging }
    trait(:with_scienceseeker) { association :source, factory: :scienceseeker }
    trait(:with_wikipedia) { association :source, factory: :wikipedia }
    trait(:with_twitter_search) { association :source, factory: :twitter_search }
    trait(:with_work_published_today) { association :work, factory: :work_published_today, retrieval_statuses: [] }
    trait(:with_counter_and_work_published_today) do
      association :work, factory: :work_published_today
      association :source, factory: :counter
    end
    trait(:with_crossref_and_work_published_today) do
      association :work, factory: :work_published_today
      association :source, factory: :crossref
    end

    trait(:with_counter) do
      total 500
      html 400
      pdf 100
      readers 0
      association :work, factory: :work_published_last_day
      association :source, factory: :counter
    end

    trait(:with_counter_last_day) do
      total 500
      html 400
      pdf 100
      readers 0
      association :work, factory: :work_published_last_day
      association :source, factory: :counter
      after :create do |rs|
        last_day = Time.zone.now.to_date - 1.day
        FactoryGirl.create(:day, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: last_day.year,
                                   month: last_day.month,
                                   day: last_day.day,
                                   html: rs.html,
                                   pdf: rs.pdf,
                                   readers: rs.readers,
                                   total: rs.total)
      end
    end

    trait(:with_counter_current_day) do
      total 250
      html 200
      pdf 50
      readers 0
      association :work, factory: :work_published_last_day
      association :source, factory: :counter
      after :create do |rs|
        FactoryGirl.create(:day, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: Time.zone.now.to_date.year,
                                   month: Time.zone.now.to_date.month,
                                   day: Time.zone.now.to_date.day,
                                   html: rs.html,
                                   pdf: rs.pdf,
                                   readers: rs.readers,
                                   total: rs.total)
      end
    end

    trait(:with_crossref) do
      readers 0
      total 25
      association :work, factory: :work_published_last_day
      association :source, factory: :crossref
    end

    trait(:with_crossref_last_day) do
      readers 0
      total 25
      association :work, factory: :work_published_last_day
      association :source, factory: :crossref
      after :create do |rs|
        last_day = Time.zone.now.to_date - 1.day
        FactoryGirl.create(:day, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: last_day.year,
                                   month: last_day.month,
                                   day: last_day.day,
                                   total: 20,
                                   readers: rs.readers)
      end
    end

    trait(:with_crossref_current_day) do
      readers 0
      total 20
      association :work, factory: :work_published_last_day
      association :source, factory: :crossref
      after :create do |rs|
        FactoryGirl.create(:day, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: Time.zone.now.to_date.year,
                                   month: Time.zone.now.to_date.month,
                                   day: Time.zone.now.to_date.day,
                                   total: rs.total,
                                   readers: rs.readers)
      end
    end

    trait(:with_crossref_last_month) do
      readers 0
      total 25
      association :source, factory: :crossref
      after :create do |rs|
        last_month = Time.zone.now.to_date - 1.month
        FactoryGirl.create(:month, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: last_month.year,
                                   month: last_month.month,
                                   total: 20,
                                   readers: rs.readers)
      end
    end

    trait(:with_crossref_current_month) do
      readers 0
      total 20
      association :source, factory: :crossref
      after :create do |rs|
        FactoryGirl.create(:month, retrieval_status: rs,
                                   work: rs.work,
                                   source: rs.source,
                                   year: Time.zone.now.to_date.year,
                                   month: Time.zone.now.to_date.month,
                                   total: rs.total,
                                   readers: rs.readers)
      end
    end

    initialize_with { RetrievalStatus.where(work_id: work.id, source_id: source.id).first_or_initialize }
  end

  factory :day do

  end

  factory :month do
    trait(:with_work) do
      association :work, factory: :work_published_today
      after :build do |month|
        if month.work.retrieval_statuses.any?
          month.retrieval_status_id = month.work.retrieval_statuses.first.id
        else
          month.retrieval_status = FactoryGirl.create(:retrieval_status, work: month.work)
        end
      end
    end
  end

  factory :report do
    name 'error_report'
    title 'Error Report'
    description 'Reports error summary'

    factory :error_report_with_admin_user do
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :status_report_with_admin_user do
      name 'status_report'
      title 'Status Report'
      description 'Reports application status'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :work_statistics_report_with_admin_user do
      name 'work_statistics_report'
      title 'Article Statistics Report'
      description 'Generates CSV file with ALM for all works'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :fatal_error_report_with_admin_user do
      name 'fatal_error_report'
      title 'Fatal Error Report'
      description 'Reports when a fatal error has occured'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :stale_source_report_with_admin_user do
      name 'stale_source_report'
      title 'Stale Source Report'
      description 'Reports when a source has not been updated'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :missing_workers_report_with_admin_user do
      name 'missing_workers_report'
      title 'Missing Workers Report'
      description 'Reports when workers are not running'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end
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
    duration 800
    api_key "67890"
    info "history"
    source nil
    ids "10.1371%2Fjournal.pone.000001"

    trait(:local) { api_key "12345" }
  end

  factory :api_response do
    duration 200
    total 10
    previous_total 5
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
    provider "cas"
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
    title "html ratio too high error"
    active true

    initialize_with { HtmlRatioTooHighError.where(name: name).first_or_initialize }
  end

  factory :work_not_updated_error, aliases: [:filter], class: WorkNotUpdatedError do
    type "WorkNotUpdatedError"
    name "WorkNotUpdatedError"
    title "work not updated error"
    active true

    initialize_with { WorkNotUpdatedError.where(name: name).first_or_initialize }
  end

  factory :decreasing_event_count_error, class: EventCountDecreasingError do
    type "EventCountDecreasingError"
    name "EventCountDecreasingError"
    title "decreasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountDecreasingError.where(name: name).first_or_initialize }
  end

  factory :increasing_event_count_error, class: EventCountIncreasingTooFastError do
    type "EventCountIncreasingTooFastError"
    name "EventCountIncreasingTooFastError"
    title "increasing event count error"
    source_ids [1]
    active true

    initialize_with { EventCountIncreasingTooFastError.where(name: name).first_or_initialize }
  end

  factory :api_too_slow_error, class: ApiResponseTooSlowError do
    type "ApiResponseTooSlowError"
    name "ApiResponseTooSlowError"
    title "API too slow error"
    active true

    initialize_with { ApiResponseTooSlowError.where(name: name).first_or_initialize }
  end

  factory :source_not_updated_error, class: SourceNotUpdatedError do
    type "SourceNotUpdatedError"
    name "SourceNotUpdatedError"
    title "source not updated error"
    active true

    initialize_with { SourceNotUpdatedError.where(name: name).first_or_initialize }
  end

  factory :work_type do
    name "article-journal"
    title "Journal Article"
    container "Journal"

    initialize_with { WorkType.where(name: name).first_or_initialize }
  end

  factory :relation_type do
    name "cites"
    title "Cites"
    inverse_name "is_cited_by"

    trait(:inverse) do
      name "is_cited_by"
      title "Is cited by"
      inverse_name "cites"
    end

    initialize_with { RelationType.where(name: name).first_or_initialize }
  end

  factory :relation do
    association :work
    association :related_work
    association :source, factory: :crossref
    association :relation_type

    before :create do |reference_relation|
      FactoryGirl.create(:relation_type)
      FactoryGirl.create(:relation_type, :inverse)
    end
  end

  factory :status do
    current_version "3.13"
  end

  factory :data_export do
    sequence(:name){ |i| "Zenodo Export #{i}"}
    files ["path/to/file1.txt"]
  end

  factory :zenodo_data_export, class: ZenodoDataExport, parent: :data_export do
    publication_date Time.zone.now.to_date
    title "My export"
    description "My export by Lagotto"
    creators ["John Doe"]
    keywords ["apples", "oranges", "bananas"]
  end
end
