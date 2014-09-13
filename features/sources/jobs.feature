@javascript
Feature: See jobs
  In order to make sure that we collect metrics correctly
  An admin user
  Should be able to see the jobs

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 5 articles

    Scenario: Jobs in dashboard
      When I go to the "Jobs" tab of the Sources page
      Then the table "JobsTable" should be:
         | Group | Source    | Status   | Pending | Working | Queued Articles | Stale Articles |
         | Saved | CiteULike | waiting  |         |         |                 | 5              |

    Scenario: Jobs in source view
      When I go to the "Summary" tab of source "Citeulike"
      Then the table "SummaryTable" should be:
        |                                             | Articles with Events | All Events |
        | Events                                      | 5                    | 250        |
        |                                             | Pending              | Working    |
        | Jobs                                        |                      |            |
        |                                             | Responses            | Errors     |
        | Responses in the last 24 Hours              |                      |            |
        |                                             | Average              | Maximum    |
        | Response duration in the last 24 Hours (ms) |                      |            |
