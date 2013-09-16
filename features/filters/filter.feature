@javascript
Feature: Edit filters
  In order to organize errors
  A user
  Should be able to edit a filter

  Background:
    Given I am logged in as "admin"
    And I have a filter "ApiResponseTooSlowError"

    Scenario: Filter is changed succesfully
      When I change the limit of filter "ApiResponseTooSlowError" to 20
      Then I should see the filter "ApiResponseTooSlowError"
