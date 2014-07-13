### UTILITY METHODS ###
def import_publishers
  string = "elife"
  body = File.read(fixture_path + 'publisher.json')
  stub = stub_request(:get, subject.query_url(string)).to_return(:body => body)
end

### GIVEN ###
Given /^we have a publisher with name "(.*?)" and CrossRef id (\d+)$/ do |name, id|
  pending # express the regexp above with the code you wish you had
end

### WHEN ###
When /^we have (\d+) publishers$/ do |number|

end

When /^I click on publisher "(.*?)"$/ do |name|
  pending # express the regexp above with the code you wish you had
end

When /^I search for publisher "(.*?)"$/ do |name|
  page.driver.render("tmp/capybara/#{name}.png")
  within(".search") do
    fill_in 'query', :with => name
    click_button 'submit'
  end
end

### THEN ###
Then /^I should see (\d+) publishers$/ do |number|
  page.driver.render("tmp/capybara/publishers.png")
  page.should have_css('div.panel', :visible => true, :count => number.to_i)
end

Then /^I should see the publisher "(.*?)"$/ do |name|
  page.has_css?('a', :text => name).should be_true
end

Then /^I should see the CrossRef id (\d+) for publisher "(.*?)"$/ do |id, name|
  within(".panel-body") do
    page.has_css?('a', :text => id, :visible => true).should be_true
  end
end
