### GIVEN ###
Given /^that we have (\d+) error messages$/ do |number|
  FactoryGirl.create_list(:error_message, number.to_i)
end

### WHEN ###
When /^I click on the "(.*?)" button$/ do |button_name|
  click_button button_name
  page.driver.render("tmp/capybara/#{button_name}.png")
end

### THEN ###
Then /^I should see (\d+) error messages$/ do |number|
  page.has_css?('div.error_message', :visible => true, :count => number.to_i).should be_true
end

Then /^I should see the "(.*?)" error number$/ do |error_number|
  page.should have_content error_number
end

Then /^I should see the "(.*?)" error message$/ do |error_message|
  page.should have_content error_message
end

Then /^I should see the "(.*?)" class name$/ do |class_name|
  page.should have_content class_name
end

Then /^I should see the "(.*?)" target url$/ do |target_url|
  page.has_css?('div.collapse', :text => target_url, :visible => true)
end

Then /^I should not see the "(.*?)" target url$/ do |target_url|
  page.has_css?('div.collapse', :text => target_url, :visible => false)
end

Then /^I should see the "(.*?)" status$/ do |status|
  page.has_css?('div.collapse', :text => status, :visible => true)
end