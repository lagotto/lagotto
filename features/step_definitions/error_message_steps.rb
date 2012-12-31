### GIVEN ###

### WHEN ###

### THEN ###
Then /^I should see the "(.*?)" error number$/ do |error_number|
  page.should have_content error_number
end

Then /^I should see the "(.*?)" error message$/ do |error_message|
  page.should have_content error_message
end