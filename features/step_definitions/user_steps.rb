### UTILITY METHODS ###
def create_user
  @user = FactoryGirl.create(:user)
end

def find_user
  @user = FactoryGirl.create(:user)
end

def delete_user
  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit '/users/auth/cas'
  find_user
end

def sign_in
  visit '/users/auth/cas'
  find_user
end

### GIVEN ###
Given /^we have a user with role "(.*?)"$/ do |role|
  FactoryGirl.create(:user, role: role, authentication_token: "12345")
end

Given /^we have (\d+) users$/  do |number|
  FactoryGirl.create_list(:user, number.to_i - 1)
end

Given /^we have user "(.*?)" with name "(.*?)"$/ do |username, name|
  FactoryGirl.create(:user, username: username, name: name)
end

Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  step "I am logged in as \"user\""
end

Given /^I am logged in as "(.*?)"$/ do |role|
  if role == "admin"
    @user = FactoryGirl.create(:admin_user)
  else
    @user = FactoryGirl.create(:user, role: role, authentication_token: "12345")
  end
  visit '/users/auth/cas'
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  delete_user
end

### WHEN ###
When /^I sign in$/ do
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I return to the site$/ do
  visit '/'
end

When /^I go to my account page$/ do
  visit '/users/me'
end

When /^I click on user "(.*?)"$/ do |username|
  page.driver.render("tmp/capybara/#{username}.png")
  user = User.find_by_username(username)
  click_link "link_#{user.id}"
end

When /^I click on the Delete button for user "(.*?)" and confirm$/ do |username|
  user = User.find_by_username(username)
  within("#user_#{user.id}") do
    click_link "#{user.id}-delete"
  end
end

When /^I click on the "(.*?)" submenu of button Edit for user "(.*?)"$/ do |menu_item, username|
  role = menu_item.split.last.downcase
  user = User.find_by_username(username)
  within("#user_#{user.id}") do
    click_link "#{user.id}-update"
    click_link "#{user.id}-update-#{role}"
  end
end

### THEN ###
Then /^I should see (\d+) user[s]?$/ do |number|
  page.should have_css('div.panel', :visible => true, :count => number.to_i)
end

Then /^I should see user "(.*?)"$/ do |username|
  user = User.find_by_username(username)
  page.should have_css("a#link_#{user.id}")
end

Then /^I should not see user "(.*?)"$/ do |username|
  user = User.find_by_username(username)
  page.should_not have_css("a#link_#{user.id}")
end

Then /^I should be signed in$/ do
  # sign_out menu item is hidden in dropdown
  page.should have_css('#sign_out', :visible => false)
  page.should_not have_css('#sign_in', :visible => false)
end

Then /^I should be signed out$/ do
  # sign_in menu item is hidden in dropdown
  page.should have_css('#sign_in', :visible => false)
  page.should_not have_css('#sign_out', :visible => false)
end

Then /^I should reach the Sign In page$/ do
  page.should have_css('#sign_in')
end

Then /^I should see the "(.*?)" button$/ do |title|
  page.should have_link(title)
end

Then /^I should not see the "(.*?)" button$/ do |title|
  page.should_not have_link(title)
end

Then(/^I should see the API key$/) do
  page.should have_css('dt', :text => "API Key")
end

Then /^I should see the "(.*?)" role for user "(.*?)"$/ do |role, username|
  user = User.find_by_username(username)
  within("#user_#{user.id}") do
    page.should have_content role
  end
end
