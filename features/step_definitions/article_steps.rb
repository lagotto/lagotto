### UTILITY METHODS ###

def create_submission
  @submission ||= { :doi => "10.1371/journal.pcbi.1000204", :title => "Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web",
    :published_on => "2008-10-31" }
end

def create_article
  @article = create(:article)
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
  create_article
end

Given /^an article does not exist$/ do
  create_submission
  delete_article
end

### WHEN ###
When /^I add the article with all required information$/ do
  create_article
end

### THEN ###
Then /^I should see the article$/ do
  page.should have_content 'Article was successfully created.'
end