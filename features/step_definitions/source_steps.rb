### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Given /^the source "(.*?)" exists$/ do |display_name|
  @source = FactoryGirl.create(:citeulike)
end

Given /^that the status of source "(.*?)" is "(.*?)"$/ do |display_name, status|
  if status == "inactive"
    @source = FactoryGirl.create(:source, active: 0)
  elsif status == "active"
    @articles = FactoryGirl.create_list(:article_with_events, 10)
  elsif status == "disabled"
    @source = FactoryGirl.create(:source, disable_until: (Time.now + 1.hour))
  end
  
end

### WHEN ###
When /^I go to the configuration of source "(\w+)"$/ do |display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
  click_link "Configuration"
  page.driver.render("tmp/capybara/configuration.png")
end

When /^I go to the source "(.*?)"$/ do |display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
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

When /^I uncheck "(.*?)"$/ do |checkbox|
  uncheck checkbox
end

When /^I submit the form$/ do
  click_button "Save"
end

When /^I go to the source overview$/ do
  visit sources_path
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

Then /^I should see that the source is "(.*?)"$/ do |status|
  page.should have_content status
  page.driver.render("tmp/capybara/#{status}.png")
end

Then /^I should see the image "(.+)"$/ do |image|
    page.should have_xpath("//img[@src=\"/assets/#{image}\"]")
end