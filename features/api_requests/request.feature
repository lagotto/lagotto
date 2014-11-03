@javascript
Feature: Show API requests
  In order to make sure that we collect metrics correctly
  An admin user
  Should see the number and average duration of API requests

  Background:
    Given I am logged in as "admin"

    Scenario: Seeing that there are no API requests
      When I go to the "Users" page
      And click on the "api_requests" button
      Then I should see that no API requests were made

    Scenario: Seeing request information
      Given we have 3 API requests
      When I go to the "Users" page
      And click on the "api_requests" button
      Then I should see 3 API requests were made

    Scenario: Only load 10,000 API requests
      Given we have 10005 API requests
      When I go to the "Users" page
      And click on the "api_requests" button
      Then I should see 10000 API requests were made
