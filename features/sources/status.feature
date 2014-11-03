@javascript
Feature: Status of sources
  In order to understand the status of the application
  An admin user
  Should be able to see the status of sources

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists

    Scenario Outline: I should see the status of a source
      Given the status of source "Citeulike" is "<Status>"
      When I go to the page of source "Citeulike"
      Then I should see that the source is "<Status>"

      Examples:
      | Status      |
# TODO recognize labels
#     | inactive    |
#     | disabled    |
#     | working     |
      | waiting     |
