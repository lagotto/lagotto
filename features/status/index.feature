@javascript @couchdb
Feature: View dashboard
  In order to understand the status of the application
  A user
  Should be able to get a status overview in the dashboard

  Background:
    Given I am logged in as "admin"
    And that we have added 3 documents to CouchDB
    And we have refreshed the status cache

    Scenario: Article info
      Given that we have 5 articles
      When I go to the "Status" page
      Then I should see that we have 10 articles

    Scenario: Article last 30 days info
      Given that we have 5 recent articles
      When I go to the "Status" page
      Then I should see that we have 5 recent articles

    Scenario: Events info
      Given that we have 5 articles
      And the source "Citeulike" exists
      When I go to the "Status" page
      Then I should see that we have 250 events

    Scenario: User info
      When I go to the "Status" page
      Then I should see that we have 1 user

    Scenario: Sources info
      Given the source "Citeulike" exists
      When I go to the "Status" page
      Then I should see that we have 1 active source

    Scenario: CouchDB info
      When I go to the "Status" page
      Then I should see that the CouchDB size is "5.45 KB"

    @delayed
    Scenario: Worker info
      When I go to the "Status" page
      Then I should see that we have 2 workers

    @delayed
    Scenario: Worker tab
      When I go to the "Status" page
      And I click on the "Workers" tab
      Then I should see a table with 2 workers
