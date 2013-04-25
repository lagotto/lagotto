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
    Scenario: Loading page …
      When I go to the "Events" admin page
      Then I should see the message "Loading page …" disappear
    
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
      Then the table "SummaryTable" should be:
        |                                | Pending              | Working    |
        | Jobs                           | 0                    | 0          |
        |                                | Responses            | Errors     |
        | Responses in the last 24 Hours | 0                    | 0          |
        |                                | Articles with Events | All Events |
        | Events                         | 5                    | 250        |
