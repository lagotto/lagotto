@javascript
Feature: Edit filters
  In order to organize errors
  A user
  Should be able to edit a filter

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists

    Scenario: Filter is changed succesfully
      Given I have a filter "ApiResponseTooSlowError"
      When I change the limit of filter "ApiResponseTooSlowError" to 20
      Then I should see the filter "ApiResponseTooSlowError"

    Scenario: Sources for Filter are changed succesfully
      Given I have a filter "EventCountDecreasingError"
      When I change the sources of filter "EventCountDecreasingError" to "CiteULike"
      Then I should see the filter "EventCountDecreasingError"
