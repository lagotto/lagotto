# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    doi '10.1371/journal.pcbi.1000204'
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    published_on '2008-10-31'
  end
end
