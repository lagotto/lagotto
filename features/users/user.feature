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
    Scenario: User cannot see the main admin dashboard
      When I go to the "Home" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see jobs in the admin dashboard
      When I go to the "Jobs" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see responses in the admin dashboard
      When I go to the "Responses" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see events in the admin dashboard
      When I go to the "Events" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see users in the admin dashboard
      When I go to the "Users" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see API requests in the admin dashboard
      When I go to the "API Requests" admin page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see alerts in the admin dashboard
      When I go to the "Alerts" admin page
      Then I should see the "You are not authorized to access this page." error message
