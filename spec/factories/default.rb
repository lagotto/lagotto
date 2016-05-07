FactoryGirl.define do

  factory :work, aliases: [:related_work] do
    sequence(:pid) { |n| "http://doi.org/10.1371/journal.pone.00000#{n}" }
    sequence(:doi) { |n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) { |n| "1897483#{n}" }
    sequence(:canonical_url) { |n| "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.00000#{n}" }
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    year { Time.zone.now.to_date.year - 1 }
    month { Time.zone.now.to_date.month }
    day { Time.zone.now.to_date.day }
    issued_at { Time.zone.now }
    tracked true
    csl {{}}

    registration_agency

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:published_today) do
      year { Time.zone.now.to_date.year }
      month { Time.zone.now.to_date.month }
      day { Time.zone.now.to_date.day }
      after :create do |work|
        FactoryGirl.create(:result, updated_at: Time.zone.now, work: work)
      end
    end
    trait(:published_yesterday) do
      year { (Time.zone.now.to_date - 1.day).year }
      month { (Time.zone.now.to_date - 1.day).month }
      day { (Time.zone.now.to_date - 1.day).day }
      after :create do |work|
        FactoryGirl.create(:result, updated_at: Time.zone.now - 1.day, work: work)
      end
    end

    trait :with_events do
      after :create do |work|
        FactoryGirl.create_list(:result, 5, work: work)
      end
    end

    trait :with_relations do
      after :create do |work|
        FactoryGirl.create_list(:relation, 5, work: work)
      end
    end

    factory :work_with_ids do
      sequence(:pmcid) { |n| "256885#{n}" }
      sequence(:wos) { |n| "00023796690000#{n}" }
      sequence(:scp) { |n| "3384533872#{n}" }
      sequence(:ark) { |n| "ark:/13030/m5br8st#{n}" }
    end

    factory :work_with_events_and_alerts do
      after :create do |work|
        FactoryGirl.create(:result, work: work)
        FactoryGirl.create(:notification, work: work)
      end
    end

    factory :work_with_errors do
      after :create do |work|
        FactoryGirl.create(:result, :with_errors, work: work)
      end
    end

    factory :work_with_private_citations do
      after :create do |work|
        FactoryGirl.create(:result, :with_private, work: work)
      end
    end

    factory :work_with_crossref do
      after :create do |work|
        FactoryGirl.create(:result, :with_crossref, work: work)
      end
    end

    factory :work_with_pubmed do
      after :create do |work|
        FactoryGirl.create(:result, :with_pubmed, work: work)
      end
    end

    factory :work_with_mendeley do
      after :create do |work|
        FactoryGirl.create(:result, :with_mendeley, work: work)
      end
    end

    factory :work_with_crossref_and_mendeley do
      after :create do |work|
        FactoryGirl.create(:result, :with_crossref, work: work)
        FactoryGirl.create(:result, :with_mendeley, work: work)
      end
    end

    factory :work_with_nature do
      after :create do |work|
        FactoryGirl.create(:result, :with_nature, work: work)
      end
    end

    factory :work_with_researchblogging do
      after :create do |work|
        FactoryGirl.create(:result, :with_researchblogging, work: work)
      end
    end

    factory :work_with_wos do
      after :create do |work|
        FactoryGirl.create(:result, :with_wos, work: work)
      end
    end

    factory :work_with_counter do
      after :create do |work|
        FactoryGirl.create(:result, :with_counter, work: work)
      end
    end

    factory :work_with_twitter do
      after :create do |work|
        FactoryGirl.create(:result, :with_twitter, work: work)
      end
    end

    trait(:with_datacite) do
      association :registration_agency, name: "datacite"
    end

    trait(:with_github) do
      association :registration_agency, name: "github"
    end
  end

  factory :result do
    total 25

    association :work
    association :source

    trait(:with_private) { association :source, private: true }
    trait(:with_mendeley) do
      total 10
      association :source, :mendeley
    end
    trait(:with_pubmed) { association :source, :pub_med }
    trait(:with_nature) do
      association :source, :nature
    end
    trait(:with_wos) { association :source, :wos }
    trait(:with_researchblogging) do
      association :source, :researchblogging
    end
    trait(:with_scienceseeker) do
      association :source, :scienceseeker
    end
    trait(:with_wikipedia) { association :source, :wikipedia }
    trait(:with_twitter) do
      association :source, :twitter
    end
    trait(:with_counter) do
      total 500
      association :source, :nature
    end

    trait(:with_work_published_today) { association :work, :published_today }

    trait(:with_crossref) do
      association :work, :published_yesterday
      association :source, :crossref
    end

    trait(:with_crossref_last_month) do
      association :source, :crossref
      after :create do |result|
        last_month = Time.zone.now.to_date - 1.month
        FactoryGirl.create(:month, result: result,
                                   work: result.work,
                                   source: result.source,
                                   year: last_month.year,
                                   month: last_month.month,
                                   total: 20)
      end
    end

    trait(:with_crossref_current_month) do
      association :source, :crossref
      after :create do |result|
        FactoryGirl.create(:month, result: result,
                                   work: result.work,
                                   source: result.source,
                                   year: Time.zone.now.to_date.year,
                                   month: Time.zone.now.to_date.month,
                                   total: result.total)
      end
    end

    initialize_with { Result.where(work_id: work.id, source_id: source.id).first_or_initialize }
  end

  factory :month do
    year 2015
    month 4

    association :work
    association :result
    association :source

    trait(:with_work) do
      association :work, :published_today
      after :build do |month|
        if month.work.results.any?
          month.result_id = month.work.results.first.id
        else
          month.result = FactoryGirl.create(:result, work: month.work)
        end
      end
    end

    initialize_with { Month.where(work_id: work.id, source_id: source.id, result_id: result.id).first_or_initialize }
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

  factory :notification do
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

    factory :notification_with_source do
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
    agent_id 1
  end

  factory :change do
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
    sequence(:authentication_token) { |n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    provider "cas"
    sequence(:uid) { |n| "joe#{n}@example.com" }

    factory :admin_user do
      role "admin"
      authentication_token "12345"
    end

    initialize_with { User.where(authentication_token: authentication_token).first_or_initialize }
  end

  factory :publisher do
    name "340"
    title 'Public Library of Science (PLoS)'
    other_names ["Public Library of Science", "Public Library of Science (PLoS)"]
    active true

    registration_agency

    trait(:with_datacite) do
      association :registration_agency, name: "datacite"
    end

    after :create do |publisher|
      FactoryGirl.create(:prefix, publisher_id: publisher.id,
                                  registration_agency_id: publisher.registration_agency.id)
    end

    initialize_with { Publisher.where(name: name).first_or_initialize }
  end

  factory :publisher_option do
    id 1
    agent_id 1
    publisher_id 1
    username "username"
    password "password"

    publisher

    initialize_with { PublisherOption.where(id: id).first_or_initialize }

    factory :publisher_option_for_pmc do
      journals "plosbiol"
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
    name "is_cited_by"
    title "Is cited by"
    inverse_name "cites"

    trait(:inverse) do
      name "cites"
      title "Cites"
      inverse_name "is_cited_by"
    end

    trait(:has_part) do
      name "has_part"
      title "Has part"
      inverse_name "is_part_of"
    end

    trait(:is_part_of) do
      name "is_part_of"
      title "Is part of"
      inverse_name "has_part"
    end

    trait(:bookmarks) do
      name "bookmarks"
      title "Bookmarks"
      inverse_name "is_bookmarked_by"
    end

    trait(:references) do
      name "references"
      title "References"
      inverse_name "is_referenced_by"
    end

    trait(:is_discussed_by) do
      name "is_discussed_by"
      title "Is discussed by"
      inverse_name "discusses"
    end

    trait(:is_viewed_by) do
      name "is_viewed_by"
      title "Is viewed by"
      inverse_name "views"
    end

    trait(:is_bookmarked_by) do
      name "is_bookmarked_by"
      title "Is bookmarked by"
      inverse_name "bookmarks"
    end

    trait(:is_referenced_by) do
      name "is_referenced_by"
      title "Is referenced by"
      inverse_name "references"
    end

    trait(:is_supplement_to) do
      name "is_supplement_to"
      title "Is supplement to"
      inverse_name "has_supplement"
    end

    trait(:has_supplement) do
      name "has_supplement"
      title "Has supplement"
      inverse_name "is_supplement_to"
    end

    trait(:is_compiled_by) do
      name "is_compiled_by"
      title "Is compiled by"
      inverse_name "compiles"
    end

    initialize_with { RelationType.where(name: name).first_or_initialize }
  end

  factory :relation do
    association :work
    association :related_work
    association :source
    association :month
    association :relation_type, :is_bookmarked_by
  end

  factory :status do
    current_version "3.13"
  end

  factory :deposit do
    uuid { SecureRandom.uuid }
    message_type "relation"
    prefix "10.1371"
    source_id "citeulike"
    source_token "citeulike_123"
    subj_id "http://www.citeulike.org/user/dbogartoit"
    subj {{ "pid"=>"http://www.citeulike.org/user/dbogartoit",
            "author"=>[{ "given"=>"dbogartoit" }],
            "title"=>"CiteULike bookmarks for user dbogartoit",
            "container-title"=>"CiteULike",
            "issued"=>"2006-06-13T16:14:19Z",
            "URL"=>"http://www.citeulike.org/user/dbogartoit",
            "type"=>"entry",
            "tracked"=> false }}
    obj_id "http://doi.org/10.1371/journal.pmed.0030186"
    relation_type_id "bookmarks"
    updated_at { Time.zone.now }
    occurred_at { Time.zone.now }

    factory :deposit_for_datacite_related do
      source_id "datacite_related"
      source_token "datacite_related_123"
      prefix "10.5061"
      subj_id "http://doi.org/10.5061/DRYAD.47SD5"
      subj nil
      obj_id "http://doi.org/10.5061/DRYAD.47SD5/1"
      relation_type_id "has_part"
      publisher_id "CDL.DRYAD"

      trait :with_works do
        association :work, pid: "http://doi.org/10.5061/DRYAD.47SD5"
        association :related_work, factory: :work, pid: "http://doi.org/10.5061/DRYAD.47SD5/1"
      end
    end

    factory :deposit_for_datacite_orcid do
      message_type "contribution"
      source_id "datacite_orcid"
      source_token "datacite_orcid_123"
      prefix "10.5061"
      subj_id "http://orcid.org/0000-0002-4133-2218"
      subj nil
      obj_id "http://doi.org/10.1594/PANGAEA.733793"
      publisher_id "TIB.PANGAEA"

      trait :with_contributor_and_work do
        association :contributor, pid: "http://orcid.org/0000-0002-4133-2218"
        association :work, pid: "http://doi.org/10.1594/PANGAEA.733793"
      end
    end

    factory :deposit_for_datacite_github do
      source_id "datacite_github"
      source_token "datacite_github_123"
      prefix "10.5281"
      subj_id "http://doi.org/10.5281/ZENODO.16668"
      subj nil
      obj_id "https://github.com/konradjk/loftee/tree/v0.2.1-beta"
      relation_type_id "is_supplement_to"
      publisher_id "CERN.ZENODO"
    end

    factory :deposit_for_github do
      source_id "github"
      source_token "github_123"
      subj_id "https://github.com/2013/9"
      subj nil
      obj_id "https://github.com/ropensci/alm"
      relation_type_id "bookmarks"
      publisher_id "CERN.ZENODO"
      registration_agency_id "github"
      total 7
    end

    factory :deposit_for_facebook do
      source_id "facebook"
      source_token "facebook_123"
      subj_id "https://facebook.com/2013/9"
      subj nil
      obj_id "http://doi.org/10.1371/journal.pmed.0020124"
      relation_type_id "references"
      total 9972
    end

    factory :deposit_for_contributor do
      message_type "contribution"
      source_id "datacite_orcid"
      source_token "datacite_orcid_123"
      subj_id "http://orcid.org/0000-0002-0159-2197"
      obj_id nil

      trait :invalid_orcid do
        subj_id "555-1212"
      end
    end

    factory :deposit_for_publisher do
      message_type "publisher"
      source_id "datacite_datacentre"
      source_token "datacite_datacentre_123"
      subj_id "ANDS.CENTRE-1"
      subj {{ "name"=>"ANDS.CENTRE-1",
              "title"=>"Griffith University",
              "issued"=>"2006-06-13T16:14:19Z",
              "registration_agency_id"=>"datacite",
              "active"=>true }}

      trait :no_publisher_title do
        subj {{ "name"=>"ANDS.CENTRE-1",
                "issued"=>"2006-06-13T16:14:19Z",
                "registration_agency_id"=>"datacite",
                "active"=>true }}
      end
    end
  end

  factory :contributor do
    pid "http://orcid.org/0000-0002-0159-2197"

    trait :with_works do
      after :create do |contributor|
        FactoryGirl.create_list(:contribution, 5, contributor: contributor)
      end
    end

    initialize_with { Contributor.where(pid: pid).first_or_initialize }
  end

  factory :contribution do
    association :contributor
    association :work
    association :source, :datacite_orcid
  end

  factory :data_export do
    sequence(:name){ |i| "Zenodo Export #{i}"}
    sequence(:url){ |i| "http://example.com/#{i}"}
  end

  factory :api_snapshot, class: ApiSnapshot, parent: :data_export do
    url "http://example.com/works"
  end

  factory :zenodo_data_export, class: ZenodoDataExport, parent: :data_export do
    publication_date Time.zone.now.to_date
    title "My export"
    description "My export by Lagotto"
    files ["path/to/file1.txt"]
    creators ["John Doe"]
    keywords ["apples", "oranges", "bananas"]
    code_repository_url "https://some.code.repository"
  end

  factory :prefix do
    name "10.1371"

    registration_agency
    publisher

    initialize_with { Prefix.where(name: name).first_or_initialize }
  end

  factory :registration_agency do
    name 'crossref'
    title 'Crossref'

    initialize_with { RegistrationAgency.where(name: name).first_or_initialize }
  end
end
