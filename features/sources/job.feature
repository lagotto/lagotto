Feature: See jobs
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the jobs

  Background:
    Given I am logged in
    And the source "Citeulike" exists
    And that we have 5 articles
    
    @javascript
    Scenario: Loading page …
      When I go to the "Jobs" admin page
      Then I should see the message "Loading page …" disappear
    
    @javascript
    Scenario: Jobs in dashboard
      When I go to the "Jobs" admin page
      Then the table "JobsTable" should contain:
        | CiteULike       | active  | 0       | 0      | 5      | 0     |
    
    @javascript
    Scenario: Jobs in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should contain:
        | Jobs            | 0       | 0       |