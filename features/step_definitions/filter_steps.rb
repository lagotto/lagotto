### GIVEN ###
Given /^I have a filter "(.*?)"$/ do |name|
  @filter = FactoryGirl.create(:filter, name: name)
end

### WHEN ###
When /^I change the limit of filter "(.*?)" to (\d+)$/ do |name, number|
  visit admin_filters_path
  click_on "#{name}-edit"
  fill_in 'Limit', :with => number
  click_on 'Save'
end

When(/^I change the sources of filter "(.*?)" to "(.*?)"$/) do |name, source|
  visit admin_filters_path
  click_on "#{name}-edit"
  sleep 5
  page.driver.render("tmp/capybara/#{source}.png")
  check source
  click_on 'Save'
end

### THEN ###
Then /^I should see the filter "(.*?)"$/ do |name|
  page.should have_content name
end
