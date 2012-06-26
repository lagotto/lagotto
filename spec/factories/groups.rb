# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name 'Citations'
  end
  
  factory :statistics_group do
    name 'Statistics'
  end
end