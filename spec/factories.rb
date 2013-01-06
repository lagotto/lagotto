FactoryGirl.define do
  
  factory :article do
    sequence(:doi) {|n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pub_med) {|n| "1897483#{n}" }
    pub_med_central 2568856
    mendeley "d4ad6910-6d06-11df-a2b2-0026b95e3eb7"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on { Time.zone.today - 1.day }
    
    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:unpublished) { published_on { Time.zone.today + 1.week } }
    
    factory :article_with_events do
      retrieval_statuses { |article| [article.association(:retrieval_status)] }
    end
    
    factory :article_with_errors do
      retrieval_statuses { |article| [article.association(:retrieval_status, :with_errors)] }
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
  end
  
  factory :group do
    name 'Citations'
    
    initialize_with { Group.find_or_create_by_name(name) }
  end
  
  factory :retrieval_history do
    sequence(:retrieved_at) { Time.zone.today - 20.hours }
    event_count { retrieval_status.event_count }
    status { event_count > 0 ? "SUCCESS" : "ERROR" }
  end
  
  factory :retrieval_status do
    event_count 50
    
    association :article
    association :source, factory: :citeulike
    
    trait(:unpublished) { association :article, :unpublished, factory: :article }
    trait(:staleness) { association :source, factory: :citeulike }
    trait(:with_errors) { event_count 0 }
    trait(:with_crossref) { association :source, factory: :cross_ref }
    trait(:with_pubmed) { association :source, factory: :pub_med }
    trait(:with_nature) { association :source, factory: :nature }
    trait(:with_researchblogging) { association :source, factory: :researchblogging }
    trait(:with_scienceseeker) { association :source, factory: :scienceseeker }
    
    before(:create) do |retrieval_status|
      FactoryGirl.create_list(:retrieval_history, 
                              5, 
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
    url "http://api.nature.com/service/blogs/posts.json?api_key=%{api_key}&doi=%{doi}"
    api_key "EXAMPLE"

    group
    
    initialize_with { Nature.find_or_create_by_name(name) }
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
  
  factory :scienceseeker, class: ScienceSeeker do
    type "ScienceSeeker"
    name "scienceseeker"
    display_name "ScienceSeeker"
    active true
    url "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}"

    group
    
    initialize_with { ScienceSeeker.find_or_create_by_name(name) }
  end
  
  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    display_name "Wikipedia"
    active true
    url "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}&maxlag=%{maxlag}"

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
    related_articles_url "http://api.mendeley.com/oapi/documents/related/%{id}"
    api_key "EXAMPLE"
    
    group
    
    initialize_with { Mendeley.find_or_create_by_name(name) }
  end
  
  factory :facebook, class: Facebook do
    type "Facebook"
    name "facebook"
    display_name "Facebook"
    active true
    api_key "EXAMPLE"

    group
    
    initialize_with { Facebook.find_or_create_by_name(name) }
  end
 
  factory :user do
    username 'example_user'
    email 'example@example.com'
    password 'please'
    password_confirmation { |u| u.password }
  end
  
  factory :error_message do
    class_name "ActiveRecord::RecordNotFound"
    message "Couldn't find Source with id=x"
    target_url "http://127.0.0.1/sources/x"
  end
end