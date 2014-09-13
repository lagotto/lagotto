@javascript
Feature: Sign in as publisher
  In order to use ALM
  Publisher users should be able to sign in

  Background:
    Given I am logged in as "publisher"

    Scenario: Publisher can see API key
      When I go to my account page
      Then I should see the API key

    Scenario: Events info
      Given we have a user with role "admin"
      And that we have 5 articles
      And the source "Citeulike" exists
      And we have refreshed the status cache
      When I go to the "Status" page
      Then I should see that we have 250 events

    Scenario: User info
      Given we have a user with role "admin"
      When I go to the "Status" page
      Then I should not see that we have 2 users

    Scenario: Publisher can see events in source view
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      And that we have 5 articles
      When I go to the "Summary" tab of source "Citeulike"
      Then the table "SummaryTable" should be:
        |                                             | Articles with Events | All Events |
        | Events                                      | 5                    | 250        |

    Scenario: Publisher cannot see the tab "Installation" in the sources dashboard
      When I go to the "Sources" page
      Then I should not see the "Installation" tab

    Scenario: Publisher can see the tab "Configuration" for an individual source in the dashboard
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the page of source "Citeulike"
      Then I should see the "Configuration" tab

    @allow-rescue
    Scenario: Publisher cannot see users in the dashboard
      When I go to the "Users" page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: User cannot see publishers in the dashboard
      When I go to the "Publishers" page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: Publisher cannot see API requests in the dashboard
      When I go to the "API Requests" page
      Then I should see the "You are not authorized to access this page." error message

    @allow-rescue
    Scenario: Publisher cannot see alerts in the dashboard
      When I go to the "Alerts" page
      Then I should see the "You are not authorized to access this page." error message
