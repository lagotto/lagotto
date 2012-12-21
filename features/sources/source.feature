Feature: Edit sources
  In order to collect metrics
  A user
  Should be able to edit sources

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 10 articles

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
  Scenario: I should see the most-cited articles all-time
    When I go to the "Most-cited" tab of source "CiteULike"
    Then I should see a list of 10 articles
  
  @javascript
  Scenario: I should see the most-cited articles from the last 7 days
    When I go to the "Most-cited (7 days)" tab of source "CiteULike"
    Then I should see a list of 7 articles
  
  @javascript
  Scenario: I should see the most-cited articles from the last 30 days
    When I go to the "Most-cited (30 days)" tab of source "CiteULike"
    Then I should see a list of 10 articles