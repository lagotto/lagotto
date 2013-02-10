### UTILITY METHODS ###

def create_submission
  @submission ||= { :doi => "10.1371/journal.pmed.0010028", :title => "Diversity and Recognition Efficiency of T Cell Responses to Cancer",
    :published_on => Date.new(2004, 11, 30) }
end

def create_article
  @article = FactoryGirl.create(:article)
  # article = Factory.build(:article)
  # visit articles_path
  # click_link 'Add another article'
  # fill_in "article[doi]", :with => article[:doi]
  # fill_in "article[title]", :with => article[:title]
  # select Date::MONTHNAMES[article[:published_on].month], :from => "article_published_on_2i"
  # select article[:published_on].day.to_s, :from => "article_published_on_3i"
  # select article[:published_on].year.to_s, :from => "article_published_on_1i"
  # click_button "Create"
end

def find_article
  @article ||= Article.first conditions: {:doi => "10.1371/journal.pcbi.1000204"}
end

def show_article
  visit article_path(@article)
end

def delete_article
  @article ||= Article.first conditions: {:doi => "10.1371/journal.pcbi.1000204"}
  @article.destroy unless @article.nil?
end

### GIVEN ###
Given /^there is an article$/ do
  delete_article
  create_article
end

Given /^that we have (\d+) articles$/ do |number|
  FactoryGirl.create_list(:article_with_events, number.to_i)
end

Given /^an article does not exist$/ do
  delete_article
end

### WHEN ###
When /^I add the article with all required information$/ do
  delete_article
  create_article
end

When /^I go to the article with the DOI "(.*?)" and no other identifiers$/ do |doi|
  article = FactoryGirl.create(:article, :doi => doi, :pub_med => "", :pub_med_central => "", :mendeley => "", :mendeley_url => "", :url => "", :published_on => "2012-10-23")
  visit article_path(article.doi)
end

When /^I go to the article with "(.*?)" for "(.*?)"$/ do |value, identifier|
  article = FactoryGirl.create(:article, identifier.to_sym => value, :mendeley_url => "http://mendeley.com", :published_on => "2012-10-23")
  visit article_path(article.doi)
end

### THEN ###
Then /^I should see the article$/ do
  #visit article_path(@article)
  #page.should have_content @article.title
end

Then /^I should see a list of articles$/ do
  page.has_css?('div.span12').should be_true
end

Then /^I should see a list of (\d+) articles$/ do |number|
  page.driver.render("tmp/capybara/#{number}.png")
  page.has_css?('div.span12', :visible => true, :count => number.to_i).should be_true
end

Then /^I should see the DOI "(.*?)" as a link$/ do |doi|
  page.driver.render("tmp/capybara/#{doi}.png")
  page.has_link?(doi, :href => "http://dx.doi.org/#{doi}").should be_true
end

Then /^I should see "(.*?)" with the "(.*?)" for the article$/ do |value, label|
  page.driver.render("tmp/capybara/#{label}.png")
  page.has_css?('dt', :text => label).should be_true
  case label
  when "Publication Date"
    page.has_css?('dd', :text => value).should be_true
  when "Mendeley UUID"
    page.has_link?(value).should be_true
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