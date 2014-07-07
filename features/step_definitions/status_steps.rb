### GIVEN ###
Given /^that we have added (\d+) documents to CouchDB$/ do |number|
  number.to_i.times do |i|
    put_alm_data("#{CONFIG[:couchdb_url]}#{i}", data: { "name" => "Fred" })
  end
end

### THEN ###
Then /^I should see that the CouchDB size is "(.*?)"$/ do |size|
  within("#couchdb_size") do
    page.should have_content('kB')
  end
end

Then /^I should see that we have (\d+) articles$/ do |number|
  page.has_css?('#articles_count', :text => number).should be_true
end

Then /^I should see that we have (\d+) recent articles$/ do |number|
  page.has_css?('#articles_last30_count', :text => number).should be_true
end

Then /^I should see that we have (\d+) events$/ do |number|
  page.has_css?('#events_count', :text => number).should be_true
end

Then /^I should see that we have (\d+) user$/ do |number|
  page.driver.render("tmp/capybara/CouchDB.png") if @wip
  page.has_css?('#users_count', :text => number).should be_true
end

Then /^I should see that we have (\d+) active source$/ do |number|
  page.has_css?('#sources_active_count', :text => number).should be_true
end
