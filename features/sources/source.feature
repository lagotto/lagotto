Feature: Edit sources
  In order to collect metrics
  An admin user
  Should be able to see and edit source settings

  Background:
    Given I am logged in
    And the source "CiteULike" exists

  @javascript
  Scenario: Group must be selected
    When I edit the source "CiteULike"
    Then "Citations" should be the only option for "Group"
    
  @javascript
  Scenario: Content from settings.yml should be displayed
    When I go to the configuration of source "CiteULike"
    Then I should see the "Job batch size" settings
    And I should see the "Batch time interval" settings
    And I should see the "Staleness interval" settings
    And I should see the "Requests per day" settings
  
  @javascript
  Scenario: I should see the most-cited articles from the last 7 days
    Given that we have 10 articles
    When I go to the "7 days" submenu of menu "Most-Cited" of source "CiteULike"
    Then I should see a list of 4 articles
  
  @javascript
  Scenario: I should see the most-cited articles from the last 30 days
    Given that we have 10 articles
    When I go to the "30 days" submenu of menu "Most-Cited" of source "CiteULike"
    Then I should see a list of 5 articles
    
  @javascript
  Scenario: I should see the most-cited articles from the last 12 months
    Given that we have 10 articles
    When I go to the "12 months" submenu of menu "Most-Cited" of source "CiteULike"
    Then I should see a list of 10 articles
    
  @javascript
  Scenario: I should see the most-cited articles all-time
    Given that we have 10 articles
    When I go to the "All-time" submenu of menu "Most-Cited" of source "CiteULike"
    Then I should see a list of 10 articles
    
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
  Scenario: I should see when a source has no events
    Given that the status of source "CiteULike" is "no events"
    When I go to the source "CiteULike"
    Then I should see that the source is "no events"
    
  @javascript
  Scenario: I should see when a source is active
    Given that the status of source "CiteULike" is "active"
    When I go to the source "CiteULike"
    Then I should see that the source is "active"