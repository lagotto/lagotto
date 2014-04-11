### GIVEN ###

### WHEN ###

### THEN ###
Then /^I should see (\d+) pending jobs? for "(.*?)"$/ do |number, display_name|
  source = Source.find_by_display_name(display_name)
  page.has_css?("#pending_count_#{source.name}", :visible => true, :count => number.to_i).should be_true
end

Then /^I should see (\d+) working jobs? for "(.*?)"$/ do |number, display_name|
  source = Source.find_by_display_name(display_name)
  page.has_css?("#working_count_#{source.name}", :visible => true, :count => number.to_i).should be_true
end