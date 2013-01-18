require 'source_helper'

### GIVEN ###
Given /^that we have (\d+) API requests$/ do |number|
  FactoryGirl.create_list(:api_request, number.to_i)
end

### WHEN ###
When /^I make (\d+) API requests$/ do |number|
  article = FactoryGirl.create(:article)
  (number.to_i).times do
    visit api_v3_article_path(article)
  end
end