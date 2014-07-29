### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Given /^the source "(.*?)" exists$/ do |name|
  FactoryGirl.create(name.underscore.downcase.to_sym)
end

Given /^"(.*?)" of source "(.*?)" is (\d+)$/ do |parameter, name, value|
  source = FactoryGirl.create(name.underscore.downcase.to_sym)
  source.update_attributes(parameter.to_sym => value)
end

Given /^the status of source "(.*?)" is "(.*?)"$/ do |name, status|
  sym_name = name.underscore.downcase.to_sym
  if status == "inactive"
    @source = FactoryGirl.create(sym_name, state_event: "inactivate")
  elsif status == "working"
    @source = FactoryGirl.create(sym_name, state_event: "work")
  elsif status == "disabled"
    @report = FactoryGirl.create(:disabled_source_report_with_admin_user)
    @source = FactoryGirl.create(sym_name, state_event: "disable")
  elsif status == "waiting"
    @source = FactoryGirl.create(sym_name, state_event: "wait")
  end
end

Given /^the screen size is "(.*?)" x "(.*?)"$/ do |width, height|
  page.driver.resize(width.to_i, height.to_i) if @wip
end

### WHEN ###
When /^I go to the "(.*?)" menu$/ do |menu|
  visit admin_root_path
  click_link menu
end

When(/^I go to the "(.*?)" URL$/) do |url|
  visit url
end

When /^I go to the submenu "(.*?)" of menu "(.*?)"$/ do |label, menu|
  click_link menu
  click_link label
  page.driver.render("tmp/capybara/#{label}.png") if @wip
end

When /^I go to the "(.*?)" tab of source "(.*?)"$/ do |tab_title, name|
  visit admin_source_path(name.underscore.downcase)
  page.driver.render("tmp/capybara/#{name}.png") if @wip
  within ("ul.nav-tabs") do
    click_link tab_title
  end
end

When /^I go to the "(.*?)" tab of the Sources admin page$/ do |tab_title|
  visit admin_sources_path
  within ("ul.nav-tabs") do
    click_link tab_title
  end
end

When /^I go to the admin page of source "(.*?)"$/ do |name|
  visit admin_source_path(name.underscore.downcase)
end

When /^I go to the source "(.*?)"$/ do |name|
  visit source_path(name.underscore.downcase)
end

When /^I edit the source "(\w+)"$/ do |name|
  visit admin_source_path(name.underscore.downcase)
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
  elsif page_title == "Home"
    visit root_path
  end
end

When /^I go to the "(.*?)" admin page$/ do |page_title|
  if page_title == "Alerts"
    title = "alerts"
  elsif page_title == "Home"
    title = ""
  elsif page_title == "API Requests"
    title = "api_requests"
  else
    title = page_title.downcase
  end
  visit "/admin/#{title}"
  page.driver.render("tmp/capybara/#{title}.png") if @wip
end

When /^I go to "(.*?)"$/ do |path|
  visit path
  page.driver.render("tmp/capybara/#{path}.png") if @wip
end

When /^I click on the "(.*?)" tab$/ do |tab_name|
  within ("ul.nav-tabs") do
    click_link tab_name
  end
  page.driver.render("tmp/capybara/#{tab_name}.png") if @wip
end

When /^I hover over the donut "(.*?)"$/ do |title|
  page.find(:xpath, "//div[@id='chart_#{title}']/*[name()='svg']").click
  page.driver.render("tmp/capybara/chart_#{title}.png") if @wip
end

### THEN ###
Then /^I should see the "(.*?)" menu item$/ do |menu_item|
  page.driver.render("tmp/capybara/#{menu_item}.png") if @wip
  page.has_css?('.dropdown-menu li', :text => menu_item, :visible => true).should be_true
end

Then /^I should see the "(.*?)" tab$/ do |tab_title|
  page.driver.render("tmp/capybara/#{tab_title}.png") if @wip
  page.has_css?('li', :text => tab_title, :visible => true).should be_true
end

Then /^I should not see the "(.*?)" tab$/ do |tab_title|
  page.driver.render("tmp/capybara/#{tab_title}.png") if @wip
  page.has_css?('li', :text => tab_title, :visible => true).should_not be_true
end

Then /^I should see the title "(.*?)"$/ do |title|
  page.has_css?('h1', :text => title, :visible => true).should be_true
end

Then /^I should see the subtitle "(.*?)"$/ do |title|
  page.has_css?('h4', :text => title, :visible => true).should be_true
end

Then /^the chart should show (\d+) events for "(.*?)"$/ do |number, display_name|
  # page.driver.render("tmp/capybara/#{number}.png")
  page.has_content?(number).should be_true
  page.has_content?(display_name).should be_true
end

Then /^I should not see a blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Then /^"(.*?)" should be one option for "(.*?)"$/ do |value, field|
  page.has_select?('source_staleness_week', :with_options => [value]).should be_true
end

Then /^I should see the "(.*?)" column$/ do |column_title|
  page.has_css?('th', :text => column_title, :visible => true).should be_true
end

Then /^I should not see the "(.*?)" column$/ do |column_title|
  page.has_css?('th', :text => column_title, :visible => true).should_not be_true
end

Then /^I should see the donut "(.*?)"$/ do |title|
  page.find(:xpath, "//div[@id='chart_#{title}']/*[name()='svg']").should be_true
end

Then /^I should see the tooltip$/ do
  page.has_css?('div.tooltip').should be_true
end

Then /^I should see the "(.*?)" settings$/ do |parameter|
  page.should have_content parameter
end

Then /^I should see that the source is "(.*?)"$/ do |status|
  page.driver.render("tmp/capybara/#{status}.png") if @wip
  page.should have_content status
end

Then /^I should not see the "(.*?)" link in the menu bar$/ do |link_text|
  if link_text == "Home"
    page.has_css?('a', :text => CONFIG[:useragent], :visible => true).should_not be_true
  else
    page.has_css?('div.collapse ul li a', :visible => true).should_not be_true
    page.driver.render("tmp/capybara/#{link_text}_link.png") if @wip
  end
end

Then /^I should see the image "(.+)"$/ do |image|
  page.has_css?("img[src='/assets/#{image}']").should be_true
end

Then /^the table "(.*?)" should be:$/ do |table_name, expected_table|
  page.driver.render("tmp/capybara/#{table_name}.png") if @wip
  rows = find("table##{table_name}").all('tr')
  table = rows.map { |r| r.all('th,td').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see a row of "(.*?)"$/ do |chart|
  page.has_css?("div#chart_#{chart} .chart .slice").should be_true
end

Then /^I should see (\d+) bookmarks$/ do |number|
  page.driver.render("tmp/capybara/#{number}_bookmarks.png") if @wip
  page.has_css?('#alm-count-citeulike-saved', :text => number).should be_true
end

Then /^I should see (\d+) stale articles? for "(.*?)"$/ do |number, name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/stale_articles_for_#{name.underscore.downcase}_#{source.human_state_name}.png") if @wip
  page.has_css?("#stale_count_#{name.underscore.downcase}", :text => number).should be_true
end

Then /^I should not see stale articles? for "(.*?)"$/ do |name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/stale_articles_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_no_content?("#stale_count_#{name.underscore.downcase}").should be_true
end

Then /^I should see (\d+) queued articles? for "(.*?)"$/ do |number, name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/queued_articles_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_css?("#queued_count_#{name.underscore.downcase}", :text => number).should be_true
end

Then /^I should not see queued articles? for "(.*?)"$/ do |name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/queued_articles_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_no_content?("#queued_count_#{name.underscore.downcase}").should be_true
end
