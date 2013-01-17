Feature: See responses from sources
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the responses from the last 24 hours and 30 days

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 5 articles
    
    @javascript
    Scenario: Responses from last 24 hours in dashboard
      When I go to the "Responses" admin page
      Then the table "ResponsesTable" should contain:
        | CiteULike                      | active  | 0                   | 0                 |
    
    @javascript
    Scenario: Responses from last 24 hours in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        |                                | Success | No Events            | Errors            |
        | Responses in the last 24 Hours | 0       | 0                    | 0                 |
                
    @javascript
    Scenario: Responses from last 30 days in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        |                                | Success | No Events            | Errors            |
        | Responses in the last 30 Days  | 25      | 0                    | 0                 |