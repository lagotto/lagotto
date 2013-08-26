require 'source_helper'

### GIVEN ###
Given /^that we have added (\d+) documents to CouchDB$/ do |number|
  number.to_i.times do |i|
    put_alm_data("#{APP_CONFIG['couchdb_url']}#{i}", data: { "name" => "Fred" })
 end
end

### THEN ###
Then /^I should see that the CouchDB size is "(.*?)"$/ do |size|
  page.has_css?('h1#couchdb', :text => size).should be_true
end

Then(/^I should see the message "(.*?)" disappear$/) do |message|
  page.has_no_css?('div#loading').should be_true
end

Then(/^I should see that we have (\d+) articles$/) do |number|
  page.has_css?('h1#article', :text => number).should be_true
end

Then(/^I should see that we have (\d+) events$/) do |number|
  page.has_css?('h1#event', :text => number).should be_true
end

Then(/^I should see that we have (\d+) user$/) do |number|
  page.driver.render("tmp/capybara/CouchDB.png")
  page.has_css?('h1#user', :text => number).should be_true
end
