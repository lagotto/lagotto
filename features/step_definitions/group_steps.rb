### UTILITY METHODS ###

def build_group
  @group = FactoryGirl.build(:group)
end

def delete_group
  @group ||= Group.first conditions: {:name => 'Citations'}
  @group.destroy unless @group.nil?
end

### GIVEN ###
Given /^I have a group "(.*?)"$/ do |group_name|
  @group = FactoryGirl.create(:group, name: group_name)
end

### WHEN ###
When /^I change the name of group "(.*?)" to "(.*?)"$/ do |group_name, new_name|
  visit admin_sources_path
  click_on "#{group_name}-edit"
  fill_in 'Name', :with => new_name
  click_on 'Save'
end

When /^I delete the group "(.*?)"$/ do |group_name|
  visit admin_sources_path
  click_on "#{group_name}-delete"
end

When /^I add the group "(.*?)"$/ do |group_name|
  visit admin_sources_path
  click_on "New"
  fill_in 'group_name', :with => group_name
  click_on 'Save'
end

### THEN ###
Then /^I should see the group "(.*?)"$/ do |group_name|
  page.should have_content group_name
end

Then /^I should not see the group "(.*?)"$/ do |group_name|
  page.should_not have_content group_name
end

Then /^I should see the error "(.*?)"$/ do |error|
  page.driver.render("tmp/capybara/#{error}.png")
  page.should have_content error
end