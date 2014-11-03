@javascript
Feature: See events for article
  In order to get to individual events
  We should be able to see a list of individual events for an article

  Background:
    Given we have a user with role "admin"
    And the source "Crossref" exists
    And there is an article

    Scenario: See events
#      When I go to the article
#      And click on the "Events" tab
#      Then I should see a list of 50 events
