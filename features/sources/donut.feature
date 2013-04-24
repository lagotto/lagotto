Feature: See donut visualizations for source
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the status and events

  Background:
    Given I am logged in
    And the source "Citeulike" exists
    And that we have 5 articles
    
    @javascript
    Scenario Outline: Status of articles
    When I go to the "Summary" tab of source "CiteULike"
    Then I should see the donut "<Name>" 
    
    Examples:
    | Name   | 
    | status |
    | day    |
    | month  |