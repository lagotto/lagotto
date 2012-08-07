# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    doi '10.1371/journal.pcbi.1000204'
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on '2008-10-31'
    
    trait :cited do
      doi '10.1371/journal.pone.0000001'
    end
        
    trait :uncited do
      doi '10.1371/journal.pone.0000002'
    end
        
    trait :mix_cited do
      doi '10.1371/journal.pone.0000003'
    end   
    
  end
end
