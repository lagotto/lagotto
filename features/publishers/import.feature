@javascript
Feature: Manage publishers
  In order to manage ALM
  Admin users should be able to import publisher information

  Background:
    Given I am logged in as "admin"

    Scenario: See list of publishers
      And I go to the "Publishers" page
      And I search for publisher "elife"
      Then I should see 5 publishers

    Scenario: Search for publisher
      Given we have a publisher with name "Public Library of Science" and CrossRef id 340
      When I go to the "Publishers" page
      And I search for publisher "Public Library of Science"
      Then I should see the publisher "Public Library of Science"

    Scenario: See publisher details
      Given we have a publisher with name "Public Library of Science" and CrossRef id 340
      When I go to the "Publishers" page
      And I search for publisher "Public Library of Science"
      And I click on publisher "Public Library of Science"
      Then I should see the CrossRef id 340 for publisher "Public Library of Science"
