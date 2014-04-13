@javascript
Feature: Responsive design of sources
  In order to be useable with mobile applications
  The layout should respond to the screen size

  Background:
    Given I am logged in as "admin"
    And the screen size is "480" x "640"
    And the source "Citeulike" exists
    And that we have 10 articles

  Scenario: I should see the responses tab
    When I go to the "Responses" tab of the Sources admin page
    Then I should see the "Errors (24 hours)" column

  Scenario: I should see the source summary tab
    When I go to the admin page of source "Citeulike"
    Then I should see the "Summary" tab