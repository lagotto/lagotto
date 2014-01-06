### GIVEN ###
Given /^there is an article$/ do
  @article = FactoryGirl.create(:article_with_events)
end

Given /^there is an article with alerts$/ do
  @article = FactoryGirl.create(:article_with_events_and_alerts)
end

Given /^there is an article with the DOI "(.*?)"$/ do |doi|
  FactoryGirl.create(:article_with_events, :doi => doi)
end

Given /^that we have (\d+) articles$/ do |number|
  FactoryGirl.create_list(:article_with_events, number.to_i)
end

Given /^that we have (\d+) recent articles$/ do |number|
  FactoryGirl.create_list(:article_for_feed, number.to_i)
end

### WHEN ###
When /^I add an article with DOI "(.*?)", date "(.*?)" and title "(.*?)"$/ do |doi, date, title|
  article = FactoryGirl.build(:article, :doi => doi, :published_on => Date.parse(date), :title => title)

  visit articles_path
  click_on "new_article"

  fill_in 'article_title', :with => article.title
  fill_in 'article_doi', :with => article.doi
  select article.published_on.strftime("%Y"), :from => "article_published_on_1i"
  select article.published_on.strftime("%B"), :from => "article_published_on_2i"
  select article.published_on.strftime("%d"), :from => "article_published_on_3i"
  click_on 'Save'
  page.driver.render("tmp/capybara/articles.png")
end

When /^I go to the article$/ do
  visit article_path(@article)
  page.driver.render("tmp/capybara/#{@article.doi}.png")
end

When /^I go to the article with the DOI "(.*?)"$/ do |doi|
  visit article_path(article.doi)
end

When /^I go to the article with the DOI "(.*?)" and no other identifiers$/ do |doi|
  article = FactoryGirl.create(:article, :doi => doi, :pub_med => "", :pub_med_central => "", :mendeley => "", :url => "", :published_on => "2012-10-23")
  visit article_path(article.doi)
end

When /^I go to the article with "(.*?)" for "(.*?)"$/ do |value, identifier|
  article = FactoryGirl.create(:article, identifier.to_sym => value, :published_on => "2012-10-23")
  visit article_path(article.doi)
end

### THEN ###
Then /^I should see the article$/ do
  page.should have_content @article.title
end

Then /^I should see an article with title "(.*?)"$/ do |title|
  page.has_css?('h4 a', :text => title).should be_true
end

Then /^I should see a list of articles$/ do
  page.has_css?('h4.article').should be_true
end

Then /^I should see a list of (\d+) article[s]?$/ do |number|
  page.driver.render("tmp/capybara/#{number}.png")
  page.has_css?('h4.article', :visible => true, :count => number.to_i).should be_true
end

Then /^I should see the DOI "(.*?)" as a link$/ do |doi|
  page.driver.render("tmp/capybara/#{doi}.png")
  page.has_link?(doi, :href => "http://dx.doi.org/#{doi}").should be_true
end

Then /^I should see the error message "(.*?)"$/ do |error|
  page.driver.render("tmp/capybara/error.png")
  page.has_css?('span.error', :text => error).should be_true
end

Then /^I should see "(.*?)" with the "(.*?)" for the article$/ do |value, label|
  page.driver.render("tmp/capybara/#{label}.png")
  page.has_css?('dt', :text => label).should be_true
  case label
  when "Publication Date"
    page.has_css?('dd', :text => value).should be_true
  when "Mendeley UUID"
    page.has_css?('dd', :text => value).should be_true
  when "PubMed ID"
    page.has_link?(value, :href => "http://www.ncbi.nlm.nih.gov/pubmed/#{value}").should be_true
  when "PubMed Central ID"
    page.has_link?("PMC#{value}", :href => "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{value}").should be_true
  else
    page.has_link?(value, :href => value).should be_true
  end
end

Then /^I should not see the "(.*?)" for the article$/ do |label|
  page.has_no_css?('dt', :text => label).should be_true
end

Then(/^I should see the "(.*?)" chart$/) do |title|
   page.find(:xpath, "//div[@id='#{title}']/*[name()='svg']").should be_true
end

Then(/^I should see the "(.*?)" menu$/) do |id|
  page.has_css?("div##{id}").should be_true
end
