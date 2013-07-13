Feature: Show API requests
  In order to make sure that we collect metrics correctly
  An admin user
  Should see the number and average duration of API requests

  Background:
    Given I am logged in as "admin"
    
    @javascript
    Scenario: Seeing request information
      Given we have 3 API requests
      When I go to the submenu "API Requests" of menu "Users"
      Then I should see 3 API requests were made

    @javascript
    Scenario: Only load 10,000 API requests
      Given we have 10005 API requests
      When I go to the submenu "API Requests" of menu "Users"
      Then I should see 10000 API requests were made