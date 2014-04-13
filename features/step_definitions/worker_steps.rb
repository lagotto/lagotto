### GIVEN ###
Given /^jobs are being dispatched$/ do
  Delayed::Worker.new.work_off
end

Given /^we have (\d+) workers?$/ do |number|
  # TODO take number argument
  Delayed::Worker.new.work_off
end

### WHEN ###
When /^I wait until all jobs for "(.*?)" have been processed$/ do |name|
  page.should have_no_content("#working_count_#{name.underscore.downcase}")
end

### THEN ###
Then /^I should see (\d+) pending jobs? for "(.*?)"$/ do |number, name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/pending_jobs_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_css?("#pending_count_#{name.underscore.downcase}", :text => number).should be_true
end

Then /^I should not see pending jobs? for "(.*?)"$/ do |name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/pending_jobs_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_no_content?("#pending_count_#{name.underscore.downcase}").should be_true
end

Then /^I should see (\d+) working jobs? for "(.*?)"$/ do |number, name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/working_jobs_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_css?("#working_count_#{name.underscore.downcase}", :text => number).should be_true
end

Then /^I should not see working jobs? for "(.*?)"$/ do |name|
  source = Source.find_by_name(name.underscore.downcase)
  page.driver.render("tmp/capybara/working_jobs_for_#{name.underscore.downcase}_#{source.human_state_name}.png")
  page.has_no_content?("#working_count_#{name.underscore.downcase}").should be_true
end

Then /^I should see that we have (\d+) workers?$/ do |number|
  page.driver.render("tmp/capybara/#{number}_workers.png")
  page.has_css?("#workers_count", :text => number).should be_true
end

Then /^I should see a table with (\d+) workers?$/ do |number|
  page.driver.render("tmp/capybara/workers_table.png")
  page.has_css?("tbody tr", :count => number.to_i).should be_true
end
