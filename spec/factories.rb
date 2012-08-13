FactoryGirl.define do
  
  factory :article do
    doi '10.1371/journal.pcbi.1000204'
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on '2008-10-31'
    
    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
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
    association :source, factory: :source, strategy: :build
    
    trait(:unpublished) { association :article, :unpublished, factory: :article, strategy: :build }
    trait(:staleness) { association :source, :staleness, factory: :source, strategy: :build }
  end
  
  factory :source do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    workers 1
    staleness { [ 30.minutes, 12.hours, 14.days ] }
    
    association :group, factory: :group
  end
 
  factory :user do
    username 'example_user'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
  
end

