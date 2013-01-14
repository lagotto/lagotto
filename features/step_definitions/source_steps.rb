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
  elsif status == "no events"
    @source = FactoryGirl.create(:source)
  elsif status == "with errors"
    @articles = FactoryGirl.create_list(:article_with_errors, 10)
  end
end

Given /^the screen size is "(.*?)" x "(.*?)"$/ do |width, height|
  page.driver.resize(width.to_i, height.to_i)
end

### WHEN ###
When /^I go to the "(.*?)" tab of source "(.*?)"$/ do |tab_title, display_name|
  source = Source.find_by_display_name(display_name)
  visit admin_source_path(source)
  click_link tab_title
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

When /^I go to the "(.*?)" page$/ do |page_title|
  if page_title == "Articles"
    visit articles_path
  elsif page_title == "Sources"
    visit sources_path
  end
end

When /^I go to the "(.*?)" admin page$/ do |page_title|
  if page_title == "Jobs" 
    title = "delayed_jobs" 
  elsif page_title == "Errors" 
    title = "error_messages"
  elsif page_title == "Home" 
    title = ""
  else
    title = page_title.downcase
  end  
  visit "/admin/#{title}"
  page.driver.render("tmp/capybara/#{title}.png")
end

When /^I go to "(.*?)"$/ do |path|
  visit path
  page.driver.render("tmp/capybara/#{path}.png")
end

When /^click on the "(.*?)" tab$/ do |tab_name|
  click_link tab_name
  page.driver.render("tmp/capybara/#{tab_name}.png")
end

### THEN ###
Then /^I should not see the "(.*?)" tab$/ do |tab_title|
  page.driver.render("tmp/capybara/#{tab_title}.png")
  page.has_css?('li', :text => tab_title, :visible => false)
end

Then /^the chart should show (\d+) events for "(.*?)"$/ do |number, source_name|
  page.has_css?('text', :text => source_name, :visible => true)
  page.has_css?('text', :text => number, :visible => true)
end

Then /^I should not see a blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Then /^"(.*?)" should be the only option for "(.*?)"$/ do |value, field|
  page.has_select?("source_group_id", :options => [value]).should be_true
end

Then /^I should see the "(.*?)" column$/ do |column_title|
  page.has_css?('th', :text => column_title, :visible => true)
end

Then /^I should not see the "(.*?)" column$/ do |column_title|
  page.has_css?('th', :text => column_title, :visible => false)
end

Then /^I should see the "(.*?)" settings$/ do |parameter|
  page.should have_content parameter
end

Then /^I should see that the source is "(.*?)"$/ do |status|
  page.should have_content status
  page.driver.render("tmp/capybara/#{status}.png")
end

Then /^I should not see the "(.*?)" link in the menu bar$/ do |link_text|
  if link_text == "Home"
    page.has_css?('a', :text => APP_CONFIG['useragent'], :visible => false)
  else
    page.has_css?('a', :text => link_text, :visible => false)
    page.driver.render("tmp/capybara/#{link_text}.png")
  end
end

Then /^I should see the image "(.+)"$/ do |image|
  page.has_css?("img[src='/assets/#{image}']") 
  page.driver.render("tmp/capybara/#{image}.png")
end

Then /^the table "(.*?)" should contain:$/ do |table_name, table|  
  page.driver.render("tmp/capybara/#{table_name}.png")
  page.has_table?("#{table_name}", :rows => table.raw).should be_true
end