Feature: Edit sources
  In order to collect metrics
  A user
  Should be able to edit sources

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    
  Scenario: Group must be selected
    When I edit the source "CiteULike"
    Then "Citations" should be the only option for "Group"