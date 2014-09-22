@javascript
Feature: View publisher
  In order to collect metrics
  A user
  Should be able to see information about a publisher

  Background:
    Given I am logged in as "admin"
    And the publisher "Public Library of Science (PLoS)" exists

    Scenario: List of publishers
      When I go to the "Publishers" page
      Then I should see the publisher "Public Library of Science (PLoS)"

    Scenario: DOI prefixes
      When I go to the page of publisher "Public Library of Science (PLoS)"
      Then the DOI prefix should be "10.1371"

    Scenario: Other names
      When I go to the page of publisher "Public Library of Science (PLoS)"
      Then the other names should include "Public Library of Science"
