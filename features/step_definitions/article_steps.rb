### UTILITY METHODS ###

def create_submission
  @submission ||= { :doi => "10.1371/journal.pmed.0010028", :title => "Diversity and Recognition Efficiency of T Cell Responses to Cancer",
    :published_on => Date.new(2004, 11, 30) }
end

def create_article
  article = Factory.build(:article)
  visit articles_path
  click_link 'Add another article'
  fill_in "article[doi]", :with => article[:doi]
  fill_in "article[title]", :with => article[:title]
  select Date::MONTHNAMES[article[:published_on].month], :from => "article_published_on_2i"
  select article[:published_on].day.to_s, :from => "article_published_on_3i"
  select article[:published_on].year.to_s, :from => "article_published_on_1i"
  click_button "Create"
end

def find_article
  @article ||= Article.first conditions: {:doi => @submission[:doi]}
end

def show_article
  visit article_path(@article)
end

def delete_article
  @article ||= Article.first conditions: {:doi => @submission[:doi]}
  @article.destroy unless @article.nil?
end

### GIVEN ###
Given /^there is an article$/ do
  Factory(:article)
end

Given /^an article does not exist$/ do
  delete_article
end

Given /^that an article has no bookmark counts$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^that an article has bookmark counts$/ do
  pending # express the regexp above with the code you wish you had
end

### WHEN ###
When /^I add the article with all required information$/ do
  create_article
end

### THEN ###
Then /^I should see the article$/ do
  page.should have_content 'Article was successfully created.'
end