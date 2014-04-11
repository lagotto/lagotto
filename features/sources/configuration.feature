@javascript
Feature: Edit sources
  In order to collect metrics
  An admin user
  Should be able to see and edit source settings

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists

    Scenario: Group must be selected
      When I edit the source "Citeulike"
      Then "24 hours" should be one option for "Batch job interval"

    Scenario: Configuration options should be displayed
      When I go to the "Configuration" tab of source "Citeulike"
      Then I should see the "Job queue" settings
      And I should see the "Update interval" settings
      And I should see the "Failed queries" settings

    Scenario: Source overview should display source name
      When I go to the "Sources" page
      Then I should see the subtitle "CiteULike"

    Scenario: Source should display source name
      When I go to the admin page of source "Citeulike"
      Then I should see the title "CiteULike"