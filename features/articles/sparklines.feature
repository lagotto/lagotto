Feature: See sparklines for article
  In order to make sure that we collect metrics correctly
  We should be able to see the events for an article

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And there is an article
    
    @javascript
    Scenario: See numbers
      When I go to the article
      Then I should see 50 bookmarks
    
    # @javascript
    #   Scenario Outline: See monthly chart
    #   When I go to the article
    #   And click on the "<Range>" tab
    #   Then I should see the "<Label>" chart
    # 
    #   Examples:
    #   | Range            | Label                        |
    #   | Metrics by Day   | day-chart-citeulike-shares   |
    #   | Metrics by Month | month-chart-citeulike-shares |
    #   | Metrics by Year  | year-chart-citeulike-shares  |