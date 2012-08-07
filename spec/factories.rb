FactoryGirl.define do
  
  factory :article do
    doi '10.1371/journal.pcbi.1000204'
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on '2008-10-31'
    
    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:mix_cited) { doi '10.1371/journal.pone.0000003' }  
  end
  
  factory :group do
    name 'Citations'
  end
  
  factory :source do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    active true
    workers 1
  end
  
  factory :user do
    username 'example'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
  
end
