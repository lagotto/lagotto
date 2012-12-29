Feature: See events
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the number and sum of events

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 5 articles
    
    @javascript
    Scenario: Events in dashboard
      When I go to the "Events" admin page
      Then the table "EventsTable" should contain:
        | CiteULike       | active               | 5          | 250                     |
    
    @javascript
    Scenario: Events in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        |                 | Articles with Events | All Events | Max. Events per Article |
        | Events          | 5                    | 250        | 50                      |