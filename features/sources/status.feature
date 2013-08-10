@javascript
Feature: Status of sources
  In order to understand the status of the application
  An admin user
  Should be able to see the status of sources

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    
    Scenario Outline: I should see the status of a source
      Given that the status of source "CiteULike" is "<Status>"
      When I go to the source "CiteULike"
      Then I should see that the source is "<Status>"
      
      Examples:
      | Status      | 
      | inactive    |
      | disabled    |
      | no events   |
      | active      |