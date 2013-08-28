FactoryGirl.define do

  factory :article do
    sequence(:doi) {|n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pub_med) {|n| "1897483#{n}" }
    pub_med_central 2568856
    mendeley "46cb51a0-6d08-11df-afb8-0026b95d30b2"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on { Time.zone.today - 1.year }

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:missing_mendeley) { mendeley nil }
    trait(:unpublished) { published_on { Time.zone.today + 1.week } }

    factory :article_with_events do
      retrieval_statuses { |article| [article.association(:retrieval_status)] }
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

    factory :article_with_nature_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_pubmed)] }
    end

    factory :article_with_researchblogging_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_researchblogging)] }
    end

    factory :article_with_wos_citations do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_wos)] }
    end
  end

  factory :group do
    name 'Saved'

    initialize_with { Group.find_or_create_by_name(name) }
  end

  factory :retrieval_history do
    retrieved_at { Time.zone.now - 1.month }
    event_count { retrieval_status.event_count }
    status { event_count > 0 ? "SUCCESS" : "ERROR" }
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

    before(:create) do |retrieval_status|
      FactoryGirl.create(:retrieval_history,
                              retrieved_at: Time.zone.today - 1.year + 1.day,
                              event_count: 10,
                              retrieval_status: retrieval_status,
                              article: retrieval_status.article,
                              source: retrieval_status.source)
      FactoryGirl.create(:retrieval_history,
                              retrieval_status: retrieval_status,
                              article: retrieval_status.article,
                              source: retrieval_status.source)
    end

    initialize_with { RetrievalStatus.find_or_create_by_article_id_and_source_id(article.id, source.id) }
  end

  factory :citeulike, aliases: [:source], class: Citeulike do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    active true
    url "http://www.citeulike.org/api/posts/for/doi/%{doi}"

    group

    initialize_with { Citeulike.find_or_create_by_name(name) }
  end

  factory :copernicus, class: Copernicus do
    type "Copernicus"
    name "copernicus"
    display_name "Copernicus"
    active true
    url "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:%{doi}"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Copernicus.find_or_create_by_name(name) }
  end

  factory :counter, class: Counter do
    type "Counter"
    name "counter"
    display_name "Counter"
    active true
    url "http://www.plosreports.org/services/rest?method=usage.stats&doi=%{doi}"

    group

    initialize_with { Counter.find_or_create_by_name(name) }
  end

  factory :cross_ref, class: CrossRef do
    type "CrossRef"
    name "crossref"
    display_name "CrossRef"
    active true
    url "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
    default_url "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { CrossRef.find_or_create_by_name(name) }
  end

  factory :nature, class: Nature do
    type "Nature"
    name "nature"
    display_name "Nature"
    active true
    url "http://blogs.nature.com/posts.json?doi=%{doi}"

    group

    initialize_with { Nature.find_or_create_by_name(name) }
  end

  factory :f1000, class: F1000 do
    type "F1000"
    name "f1000"
    display_name "F1000Prime"
    active true
    url "http://linkout.export.f1000.com.s3.amazonaws.com/linkout/PLOS-intermediate.xml"
    filename "PLOS-intermediate.xml"

    group

    initialize_with { F1000.find_or_create_by_name(name) }
  end

  factory :figshare, class: Figshare do
    type "Figshare"
    name "figshare"
    display_name "Figshare"
    active true
    url "http://api.figshare.com/v1/publishers/search_for?doi=%{doi}"

    group

    initialize_with { Figshare.find_or_create_by_name(name) }
  end

  factory :pmc, class: Pmc do
    type "Pmc"
    name "pmc"
    display_name "PubMed Central Usage Stats"
    active true
    url "http://rwc-couch01.int.plos.org:5984/pmc_usage_stats/%{doi}"
    filepath "/home/alm/pmcdata/"

    group

    initialize_with { Pmc.find_or_create_by_name(name) }
  end

  factory :pub_med, class: PubMed do
    type "PubMed"
    name "pubmed"
    display_name "PubMed"
    active true
    url "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"

    group

    initialize_with { PubMed.find_or_create_by_name(name) }
  end

  factory :researchblogging, class: Researchblogging do
    type "Researchblogging"
    name "researchblogging"
    display_name "Research Blogging"
    active true
    url "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Researchblogging.find_or_create_by_name(name) }
  end

  factory :science_seeker, class: ScienceSeeker do
    type "ScienceSeeker"
    name "scienceseeker"
    display_name "ScienceSeeker"
    active true
    url "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}"

    group

    initialize_with { ScienceSeeker.find_or_create_by_name(name) }
  end

  factory :scopus, class: Scopus do
    type "Scopus"
    name "scopus"
    display_name "Scopus"
    active true
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
    active true
    url "http://rwc-couch01.int.plos.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key=%{doi}"

    group

    initialize_with { Twitter.find_or_create_by_name(name) }
  end

  factory :wos, class: Wos do
    type "Wos"
    name "wos"
    display_name "Web of Science"
    active true
    private true
    url "https://ws.isiknowledge.com:80/cps/xrpc"

    group

    initialize_with { Wos.find_or_create_by_name(name) }
  end

  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    display_name "Wikipedia"
    active true
    url "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1"

    group

    initialize_with { Wikipedia.find_or_create_by_name(name) }
  end

  factory :mendeley, class: Mendeley do
    type "Mendeley"
    name "mendeley"
    display_name "Mendeley"
    active true
    url "http://api.mendeley.com/oapi/documents/details/%{id}/?consumer_key=%{api_key}"
    url_with_type "http://api.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}&consumer_key=%{api_key}"
    url_with_title "http://api.mendeley.com/oapi/documents/search/title:%{title}/?items=10&consumer_key=%{api_key}"
    related_articles_url "http://api.mendeley.com/oapi/documents/related/%{id}?consumer_key=%{api_key}"
    api_key "EXAMPLE"

    group

    initialize_with { Mendeley.find_or_create_by_name(name) }
  end

  factory :facebook, class: Facebook do
    type "Facebook"
    name "facebook"
    display_name "Facebook"
    active true
    url "http://graph.facebook.com:443/fql?access_token=%{access_token}&q=select url, normalized_url, share_count, like_count, comment_count, total_count, click_count, comments_fbid, commentsbox_count from link_stat where url = '%{query_url}'"
    access_token "EXAMPLE"

    group

    initialize_with { Facebook.find_or_create_by_name(name) }
  end

  factory :relative_metric, class: RelativeMetric do
    type "RelativeMetric"
    name "relativemetric"
    display_name "Relative Metric"
    active true
    url "http://rwc-couch01.int.plos.org:5984/relative_metrics/_design/relative_metric/_view/average_usage?key=%{key}"
    solr_url "http://api.plos.org/search"

    group

    initialize_with { RelativeMetric.find_or_create_by_name(name) }
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
  end

  factory :error_message do
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
    api_key "12345"
    info "history"
    source nil
    ids "10.1371%2Fjournal.pone.000001"
  end
end
