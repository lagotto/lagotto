@javascript @couchdb
Feature: View admin dashboard
  In order to understand the status of the application
  An admin user
  Should be able to get a status overview in the admin dashboard

  Background:
    Given I am logged in as "admin"
    And that we have added 3 documents to CouchDB

    Scenario: Article info
      Given that we have 5 articles
      When I go to the "Home" admin page
      Then I should see that we have 10 articles

    Scenario: Article last 30 days info
      Given that we have 5 recent articles
      When I go to the "Home" admin page
      Then I should see that we have 5 recent articles

    Scenario: Events info
      Given that we have 5 articles
      And the source "Citeulike" exists
      When I go to the "Home" admin page
      Then I should see that we have 250 events

    Scenario: User info
      When I go to the "Home" admin page
      Then I should see that we have 1 user

    Scenario: Sources info
      Given the source "Citeulike" exists
      When I go to the "Home" admin page
      Then I should see that we have 1 active source

    Scenario: CouchDB info
      When I go to the "Home" admin page
      Then I should see that the CouchDB size is "2.6 kB"

    @not_teamcity
    Scenario: Worker info
      Given we have 1 worker
      When I go to the "Home" admin page
      Then I should see that we have 1 worker

    @not_teamcity
    Scenario: Worker tab
      Given we have 1 worker
      When I go to the "Home" admin page
      And I click on the "Workers" tab
      Then I should see a table with 1 worker
