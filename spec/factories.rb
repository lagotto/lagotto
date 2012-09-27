FactoryGirl.define do
  
  factory :article do
    sequence(:doi) {|n| "10.1371/journal.pone.00000#{n}" }
    pub_med 18974831
    pub_med_central 2568856
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on '2008-10-31'
    
    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:unpublished) { published_on { Time.zone.today + 1.week } }
    trait(:just_published) { published_on { Time.zone.today - 1.day } }
  end
  
  factory :group do
    name 'Citations'
  end
  
  factory :retrieval_history do
    association :retrieval_status, factory: :retrieval_status, strategy: :build
  end
  
  factory :retrieval_status do
    association :article, factory: :article, strategy: :build
    association :source, factory: :citeulike, strategy: :build
    
    trait(:unpublished) { association :article, :unpublished, factory: :article, strategy: :build }
    trait(:staleness) { association :source, :staleness, factory: :citeulike, strategy: :build }
  end
  
  factory :citeulike, class: Citeulike do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    staleness { [ 7.days ] }
    url "http://www.citeulike.org/api/posts/for/doi/%{doi}"

    association :group, factory: :group, strategy: :build
  end
  
  factory :cross_ref, class: CrossRef do
    type "CrossRef"
    name "cross_ref"
    display_name "CrossRef"
    staleness { [ 7.days ] }
    url "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
    default_url "http://www.crossref.org/openurl/?pid=%{pid}&id=doi:%{doi}&noredirect=true"
    username "EXAMPLE"
    password "EXAMPLE"

    association :group, factory: :group, strategy: :build
  end
  
  factory :pub_med, class: PubMed do
    type "PubMed"
    name "pub_med"
    display_name "PubMed"
    staleness { [ 7.days ] }
    url "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pub_med}"

    association :group, factory: :group, strategy: :build
  end
  
  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    display_name "Wikipedia"
    staleness { [ 7.days ] }
    url "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}&maxlag=%{maxlag}"

    association :group, factory: :group, strategy: :build
  end
 
  factory :user do
    username 'example_user'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.zone.now
  end
  
end