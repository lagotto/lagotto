@javascript
Feature: Manage publishers
  In order to manage ALM
  Admin users should be able to import publisher information

  Background:
    Given I am logged in as "admin"
    And we have a publisher with name "Public Library of Science (PLoS)" and CrossRef id 340

    Scenario: See list of publishers
      When I go to the "Publishers" page
      Then I should see a list of 1 publisher

    Scenario: See publisher details
      When I go to the "Publishers" page
      And I click on publisher "Public Library of Science"
      Then the CrossRef ID should be 340

    Scenario: Search for existing publisher
      When I go to the "Publishers" page
      And I click on the add button on the Publishers page
      And I search for publisher "plos"
      Then I should see the alert "No CrossRef members to add"

    Scenario: Search for new publisher
      When I go to the "Publishers" page
      And I click on the add button on the Publishers page
      And I search for publisher "elife"
      Then I should see the alert "No CrossRef members to add"
