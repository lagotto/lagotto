@javascript
Feature: Sign in as user
  In order to use ALM
  Regular users should be able to sign in
  
  Background:
    Given I am logged in as "user"

    Scenario: User can see API key
      When I go to my account page
      Then I should see the API key
    
    @allow-rescue
    Scenario: User cannot see errors
      When I go to the "Errors" admin page
      Then I should see the "CanCan::AccessDenied" error