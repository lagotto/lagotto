### UTILITY METHODS ###
def refresh
  show_article
  click_link "Refresh"
end


### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

### WHEN ###
When /^I refresh an article$/ do
  refresh
end

### THEN ###
Then /^I should not see a blog count$/ do
  page.should_not have_content "Nature Blogs"
end

