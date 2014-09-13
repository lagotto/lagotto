@javascript @delayed
Feature: Background workers
  In order to understand the status of the application
  An admin user
  Should be able to see the background workers at work

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And that we have 20 queued articles for "Citeulike"

    Scenario: See queued articles
      When I go to the "Jobs" tab of the Sources page
      Then I should see 20 queued articles for "Citeulike"

    Scenario: Working off all articles
      Given "job_batch_size" of source "Citeulike" is 200
      And "workers" of source "Citeulike" is 1
      And jobs are being dispatched
      When I go to the "Jobs" tab of the Sources page
      Then I should see 20 queued articles for "Citeulike"
      # TODO
      And I should not see working jobs for "Citeulike"
      And I should not see pending jobs for "Citeulike"

    Scenario: Working off all articles with not enough workers
      Given "job_batch_size" of source "Citeulike" is 10
      And "workers" of source "Citeulike" is 1
      And we have 1 worker
      When I go to the "Jobs" tab of the Sources page
      Then I should see 20 queued articles for "Citeulike"
      # TODO
      And I should not see working jobs for "Citeulike"
      And I should not see pending jobs for "Citeulike"
