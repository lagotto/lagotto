Feature: Add citeulike content
  In order to collect metrics
  A user
  Should be able to add citeulike bookmark counts for an article

  Background:
    Given I am logged in
    And an article exists
  
  Scenario: Bookmark counts are created succesfully
    Given that an article has no bookmark counts
    
  Scenario: Bookmark counts are updated succesfully
    Given that an article has bookmark counts