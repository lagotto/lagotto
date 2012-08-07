# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source do
    type "Citeulike"
    name "citeulike"
    display_name "CiteULike"
    active true
    workers 1
  end
end