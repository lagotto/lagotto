@javascript
Feature: Sign in as staff
  In order to monitor ALM
  Staff users should be able to see the admin dashboard

  Background:
    Given I am logged in as "staff"

    @not-teamcity
    Scenario: Staff can see jobs in source view
      Given the source "Citeulike" exists
      And that we have 5 articles
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

    Scenario: Configuration should be displayed
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should see the "Job queue" settings
      And I should see the "Update interval" settings
      And I should see the "Failed queries" settings

    Scenario: Staff cannot edited sources
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "CiteULike"
      Then I should not see the "Edit" button

    Scenario: Staff cannot edited users
      Given we have user "joeboxer" with name "Joe Boxer"
      When I go to the "Users" admin page
      And I click on user "joeboxer"
      Then I should not see the "Edit" button

    Scenario: Staff can delete alerts
      Given we have 1 alert
      When I go to the "Alerts" admin page
      And I click on the "[408] The request timed out." link
      Then I should see the "Delete" button
