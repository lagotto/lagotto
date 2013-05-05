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
  visit '/users/auth/github'
  find_user
end

def sign_in
  visit '/users/auth/github'
  find_user
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/sign_out'
end

Given /^I am logged in$/ do
  visit '/users/auth/github'
  @user = FactoryGirl.create(:user)
end

Given /^I am logged in as "(.*?)"$/ do |role|
  visit '/users/auth/github'
  @user = FactoryGirl.create(:user, :role => role)
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
  visit '/sign_out'
end

When /^I return to the site$/ do
  visit '/'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_link("Sign Out", :href => "/sign_out")
  page.should_not have_link("Sign in with Github", :href => "/users/auth/github")
end

Then /^I should be signed out$/ do
  page.should have_link("Sign in with Github", :href => "/users/auth/github")
  page.should_not have_link("Sign Out", :href => "/sign_out")
end

Then /^I should reach the Sign In page$/ do
  page.should have_link("Sign in with Github", :href => "/users/auth/github")
end