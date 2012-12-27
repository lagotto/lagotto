Feature: Status of sources
  In order to understand the status of the application
  An admin user
  Should be able to see the status of sources

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    
    @javascript
    Scenario: I should see when a source is inactive
      Given that the status of source "CiteULike" is "inactive"
      When I go to the source "CiteULike"
      Then I should see that the source is "inactive"
    
    @javascript
    Scenario: I should see when a source is disabled
      Given that the status of source "CiteULike" is "disabled"
      When I go to the source "CiteULike"
      Then I should see that the source is "disabled"
      
    @javascript
    Scenario: I should see when a source has errors
      Given that the status of source "CiteULike" is "with errors"
      When I go to the source "CiteULike"
      Then I should see that the source is "with errors"
    
    @javascript
    Scenario: I should see when a source has no events
      Given that the status of source "CiteULike" is "no events"
      When I go to the source "CiteULike"
      Then I should see that the source is "no events"
    
    @javascript
    Scenario: I should see when a source is active
      Given that the status of source "CiteULike" is "active"
      When I go to the source "CiteULike"
      Then I should see that the source is "active"