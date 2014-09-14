@javascript
Feature: Use without signing in
  In order to use ALM
  Users should not be required to sign in

    Scenario: Anonymous user can see articles
      Given we have a user with role "admin"
      And that we have 5 articles
      When I go to the "Articles" page
      Then I should see a list of 10 articles

    Scenario: Anonymous user can go to article
      Given we have a user with role "admin"
      And there is an article
      When I go to the article
      Then I should see the article

    Scenario: Anonymous user can see sources
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the "Sources" page
      Then I should see the row "CiteULike"

    Scenario: Anonymous user can go to source
      Given we have a user with role "admin"
      And the source "Citeulike" exists
      When I go to the source "Citeulike"
      Then I should see the title "CiteULike"

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
      Then I should not see that we have 1 user

    Scenario: Anonymous user cannot see the tab "Installation" in the sources dashboard
      When I go to the "Sources" page
      Then I should not see the "Installation" tab

    Scenario: Anonymous user cannot see the tab "Configuration" for an individual source in the dashboard
      Given the source "Citeulike" exists
      When I go to the page of source "Citeulike"
      Then I should not see the "Configuration" tab

    @allow-rescue
    Scenario: Anonymous user cannot see users in the dashboard
      When I go to the "Users" page
      Then I should see the "The page you are looking for doesn't exist." error message

    @allow-rescue
    Scenario: User cannot see publishers in the dashboard
      When I go to the "Publishers" page
      Then I should see the "The page you are looking for doesn't exist." error message

    @allow-rescue
    Scenario: Anonymous user cannot see API requests in the dashboard
      When I go to the "API Requests" page
      Then I should see the "The page you are looking for doesn't exist." error message

    @allow-rescue
    Scenario: Anonymous user cannot see alerts in the dashboard
      When I go to the "Alerts" page
      Then I should see the "The page you are looking for doesn't exist." error message

    @allow-rescue
    Scenario: Anonymous user can download the monthly report
      Given we have report "article_statistics_report"
      When I go to the "/files/alm_report.zip" URL
      Then I should not see the "No route matches" error message
