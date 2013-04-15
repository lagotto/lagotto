require 'source_helper'

### GIVEN ###
Given /^that we have added (\d+) documents to CouchDB$/ do |number|
  number.to_i.times do |i|
    put_alm_data("#{APP_CONFIG['couchdb_url']}#{i}", { "name" => "Fred" }.to_json)
 end
end

### THEN ###
Then /^I should see that CouchDB has (\d+) documents$/ do |number|
  page.driver.render("tmp/capybara/CouchDB.png")
  page.has_css?('p#couchdb', :text => "#{number} CouchDB document").should be_true
end

Then(/^I should see the message "(.*?)" disappear$/) do |message|
  page.has_no_css?('div#loading').should be_true
end