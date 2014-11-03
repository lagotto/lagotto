### WHEN ###
When /^I go to the "(.*?)" documentation page$/ do |title|
  visit doc_path(title.downcase)
end

### THEN ###
Then /^I should see the "(.*?)" title$/ do |title|
  page.driver.render("tmp/capybara/#{title}.png") if @wip
  page.has_css?('h1', :text => title.tr('-', ' ')).should be true
end

Then /^I should see the documentation$/ do
  page.has_css?('.markdown').should be true
end
