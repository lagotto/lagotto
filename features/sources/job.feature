@javascript
Feature: See jobs
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the jobs

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 5 articles

    Scenario: Loading page …
      When I go to the "Jobs" admin page
      Then I should see the message "Loading page …" disappear

    @not-teamcity
    Scenario: Jobs in dashboard
      When I go to the "Jobs" admin page
      Then the table "JobsTable" should be:
        | Source    | Status  | Pending | Working | Stale Articles | Queued Articles |
        | CiteULike | working | 0       | 0       | 5              | 0               |

    @not-teamcity
    Scenario: Jobs in source view
      When I go to the "Summary" tab of source "CiteULike"
      Then the table "SummaryTable" should be:
        |                                             | Pending              | Working    |
        | Jobs                                        | 0                    | 0          |
        |                                             | Responses            | Errors     |
        | Responses in the last 24 Hours              | 0                    | 0          |
        |                                             | Average              | Maximum    |
        | Response duration in the last 24 Hours (ms) | 0                    | 0          |
        |                                             | Articles with Events | All Events |
        | Events                                      | 5                    | 250        |
