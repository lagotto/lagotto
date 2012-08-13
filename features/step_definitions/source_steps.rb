### UTILITY METHODS ###
def refresh
  show_article
  click_link "Refresh"
end


### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Given /^I edit the source "(\w+)"$/ do |display_name|
  @source = FactoryGirl.create(:source)
  visit edit_source_path(@source)
end

### WHEN ###
When /^I refresh an article$/ do
  refresh
end

### THEN ###
Then /^I should not see a blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Then /^"(.*?)" should be the only option for "(.*?)"$/ do |value, field|
  page.has_select?("source_group_id", :options => [value]).should be_true
end