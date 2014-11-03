@javascript
Feature: Sign in as staff
  In order to monitor ALM
  Staff users should be able to see the dashboard

  Background:
    Given I am logged in as "staff"

    Scenario: Staff can see jobs in source view
      Given the source "Citeulike" exists
      And that we have 5 articles
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

    Scenario: Configuration should be displayed
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "Citeulike"
      Then I should see the "Job queue" settings
      And I should see the "Update interval" settings
      And I should see the "Failed queries" settings

    Scenario: Staff cannot edit sources
      Given the source "Citeulike" exists
      When I go to the "Configuration" tab of source "Citeulike"
      Then I should not see the "Edit" button

    Scenario: Staff cannot edit users
      Given we have user "joeboxer" with name "Joe Boxer"
      When I go to the "Users" page
      And I click on user "joeboxer"
      Then I should not see the "Edit" button

    Scenario: Staff cannot edit publishers
      When I go to the "Publishers" page
      Then I should not see the "Add" button

   # Scenario: Staff can delete alerts
   #   Given we have 1 alert
   #   When I go to the "Alerts" page
   #   And I click on the "[408] The request timed out." link
   #   Then I should see the "Delete" button
