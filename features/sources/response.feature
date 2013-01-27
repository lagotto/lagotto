Feature: See responses from sources
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the responses from the last 24 hours and 30 days

  Background:
    Given I am logged in
    And the source "Citeulike" exists
    And that we have 5 articles
                
    @javascript
    Scenario: Responses from last 30 days in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        |                                | Events  | No Events            | Errors            |
        | Responses in the last 24 Hours | 5       | 0                    | 0                 |
        |                                | Events  | No Events            | Errors            |
        | Responses in the last 30 Days  | 5       | 0                    | 0                 |