### WHEN ###
When /^I go to the "(.*?)" documentation page$/ do |title|
  visit doc_path(title)
end

### THEN ###
Then /^I should see the "(.*?)" title$/ do |title|
  page.driver.render("tmp/capybara/#{title}.png")
  page.has_css?('h1', :text => title.tr('-', ' ')).should be_true
end