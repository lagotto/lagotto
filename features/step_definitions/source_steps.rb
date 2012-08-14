### UTILITY METHODS ###
def refresh
  show_article
  click_link "Refresh"
end

### GIVEN ###
Given /^that an article has no blog count$/ do
  page.should_not have_content "Nature Blogs"
end

Given /^the source "(.*?)" exists$/ do |display_name|
  @source = FactoryGirl.create(:source, :display_name => display_name)
end

### WHEN ###
When /^I edit the source "(\w+)"$/ do |display_name|
  source = Source.find_by_display_name(display_name)
  visit edit_source_path(source)
end

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