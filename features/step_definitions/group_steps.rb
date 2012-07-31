### UTILITY METHODS ###

def create_group
  @group = create(:group)
end

def find_group
  @group ||= Group.first conditions: {:doi => @submission[:doi]}
end

def show_group
  visit group_path(@group)
end

def delete_group
  @group ||= Group.first conditions: {:name => 'Citations'}
  @group.destroy unless @group.nil?
end

### GIVEN ###
Given /^a group does not exist$/ do
  delete_group
end

Given /^I have a group named Citations$/ do
  page.should have_content 'Citations' 
end

### WHEN ###
When /^I add the group with all required information$/ do
  create_group
end

When /^I add the group without a name$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I delete the group$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I edit the group with all required information$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I edit the group without giving a name$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change the group name to Statistics$/ do
  pending # express the regexp above with the code you wish you had
end

### THEN ###
Then /^I should see the group$/ do
  page.should have_content 'Group was successfully created.'
end

Then /^I should not see the group Citations$/ do
  page.should_not have_content "Citations"
end

Then /^I should see an error$/ do
  pending # express the regexp above with the code you wish you had
end