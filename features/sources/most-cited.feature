Feature: Display most-cited articles
  In order to understand metrics
  A user
  Should be able to see the most-cited articles

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 10 articles
  
    @javascript
    Scenario: I should see the most-cited articles from the last 7 days
      When I go to the "7 days" submenu of menu "Most-Cited" of source "CiteULike"
      Then I should see a list of 4 articles
  
    @javascript
    Scenario: I should see the most-cited articles from the last 30 days
      When I go to the "30 days" submenu of menu "Most-Cited" of source "CiteULike"
      Then I should see a list of 5 articles
    
    @javascript
    Scenario: I should see the most-cited articles from the last 12 months
      When I go to the "12 months" submenu of menu "Most-Cited" of source "CiteULike"
      Then I should see a list of 10 articles
    
    @javascript
    Scenario: I should see the most-cited articles all-time
      When I go to the "All-time" submenu of menu "Most-Cited" of source "CiteULike"
      Then I should see a list of 10 articles