### UTILITY METHODS ###
def import_publishers
  string = "elife"
  body = File.read(fixture_path + 'publisher.json')
  stub = stub_request(:get, subject.query_url(string)).to_return(:body => body)
end

### GIVEN ###
Given /^we have a publisher with name "(.*?)" and CrossRef id (\d+)$/ do |name, id|
  FactoryGirl.create(:publisher, :name => name, :crossref_id => id)
end

### WHEN ###
When /^I click on publisher "(.*?)"$/ do |name|
  click_link name
end

When /^I click on the add button on the Publishers page$/ do
  visit publishers_path
  click_link "new_publisher"
  page.driver.render("tmp/capybara/#{button_name}.png") if @wip
end


When /^I search for publisher "(.*?)"$/ do |name|
  within(".search") do
    fill_in 'query', :with => name
    click_button 'search_submit'
  end
end

### THEN ###
Then /^I should see a list of (\d+) publishers?$/ do |number|
  # page.driver.render("tmp/capybara/#{number}_publishers.png")
  page.has_css?('h4.article', :count => number).should be_true
end

Then /^I should see the publisher "(.*?)"$/ do |name|
  # page.driver.render("tmp/capybara/#{name}.png")
  page.has_css?('a', :text => name).should be_true
end

Then /^I should see the CrossRef id (\d+) for publisher "(.*?)"$/ do |id, name|
  within(".dl-horizontal") do
    page.has_css?('a', :text => id, :visible => true).should be_true
  end
end

Then /^I should see the alert "(.*?)"$/ do |text|
  # page.driver.render("tmp/capybara/alert.png")
  page.has_css?('div.alert', :text => text, :visible => true).should be_true
end
