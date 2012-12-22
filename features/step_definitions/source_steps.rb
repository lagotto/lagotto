### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Given /^the source "(.*?)" exists$/ do |display_name|
  @source = FactoryGirl.create(:citeulike)
end

### WHEN ###
When /^I go to the configuration of source "(\w+)"$/ do |display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
  click_link "Configuration"
  page.driver.render("tmp/capybara/configuration.png")
end

When /^I go to the "(.*?)" submenu of menu "(.*?)" of source "(.*?)"$/ do |label, menu, display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
  click_link menu
  click_link label
  page.driver.render("tmp/capybara/#{label}.png")
end

When /^I edit the source "(\w+)"$/ do |display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
  click_link "Configuration"
  click_link "Edit"
end

### THEN ###
Then /^I should not see a blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Then /^"(.*?)" should be the only option for "(.*?)"$/ do |value, field|
  page.has_select?("source_group_id", :options => [value]).should be_true
end

Then /^I should see the "(.*?)" settings$/ do |parameter|
  page.should have_content parameter
end