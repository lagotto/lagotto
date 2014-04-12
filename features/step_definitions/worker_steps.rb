### GIVEN ###
Given /^we have (\d+) worker$/ do |number|
  pending # express the regexp above with the code you wish you had
end

### WHEN ###

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