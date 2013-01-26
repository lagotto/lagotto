Feature: See events
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the number and sum of events

  Background:
    Given I am logged in
    And the source "Citeulike" exists
    And the source "CrossRef" exists
    And that we have 5 articles
    
    @javascript
    Scenario: Events for articles in dashboard
      When I go to the "Events" admin page
      Then the chart should show 5 events for "CiteULike"
      
    @javascript
    Scenario: Events in dashboard
      When I go to the "Events" admin page
      And click on the "All Events" tab
      Then the chart should show 250 events for "CiteULike"
    
    @javascript
    Scenario: Events in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        | Events          | 5                              | 250        | 50                                     |