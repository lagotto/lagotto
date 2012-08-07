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

Given /^an article does not exist$/ do
  delete_article
end

### WHEN ###
When /^I add the article with all required information$/ do
  delete_article
  create_article
end

### THEN ###
Then /^I should see the article$/ do
  #visit article_path(@article)
  #page.should have_content @article.title
end