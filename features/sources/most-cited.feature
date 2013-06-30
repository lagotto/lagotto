@javascript
Feature: Display most-cited articles
  In order to understand metrics
  A user
  Should be able to see the most-cited articles

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 10 articles
      
    Scenario Outline: I should see the most-cited articles
      When I go to the "<Submenu>" submenu of menu "Most-Cited" of source "CiteULike"
      Then I should see a list of <Articles> articles
      
      Examples: 
        | Submenu   | Articles |
        | 7 days    | 10       |
        | 30 days   | 10       |
        | 12 months | 10       |
        | All-time  | 10       |