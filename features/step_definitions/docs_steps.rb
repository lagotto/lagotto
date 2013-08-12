### WHEN ###
When /^I go to the "(.*?)" documentation page$/ do |title|
  visit doc_path(title)
end

### THEN ###
Then /^I should see the "(.*?)" title$/ do |title|
  page.driver.render("tmp/capybara/#{title}.png")
  page.has_css?('h1', :text => title.tr('-', ' ')).should be_true
end

Then /^I should see the "(.*?)" sidebar$/ do |title|
  within(".sidebar-nav-fixed-lower") do
    page.has_css?('.nav-header', :text => title).should be_true
  end
end
