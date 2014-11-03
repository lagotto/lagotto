@javascript
Feature: Display most-cited articles
  In order to understand metrics
  A user
  Should be able to see the most-cited articles

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 5 recent articles

    Scenario: I should see the most-cited articles
      When I go to the source "Citeulike"
      Then I should see 5 cited articles

    Scenario: I should see the most-cited articles in the dashboard
      When I go to the "Most-Cited" tab of source "Citeulike"
      Then I should see a list of 5 articles
