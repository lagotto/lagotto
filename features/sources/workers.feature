@javascript
Feature: Background workers
  In order to understand the status of the application
  An admin user
  Should be able to see the background workers at work

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists with 1 worker and a job batch size of 200
    And we have 20 queued articles for "Citeulike"

    Scenario: See queued articles
      When I go to the "Sources" admin page
      Then I should see 20 queued articles for "Citeulike"

    Scenario: Working off all articles
      Given we have 1 worker
      When I go to the "Sources" admin page
      Then I should see 20 queued articles for "Citeulike"
      And I should see 1 working job for "Citeulike"
      And I should see 0 pending jobs for "Citeulike"

    Scenario: Working off all articles with not enough workers
      Given we have 1 worker
      And the source "Citeulike" exists with 1 worker and a job batch size of 10
      And we have 20 queued articles for "Citeulike"
      When I go to the "Sources" admin page
      Then I should see 20 queued articles for "Citeulike"
      And I should see 1 active job for "Citeulike"
      And I should see 2 pending jobs for "Citeulike"