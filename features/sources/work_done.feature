@javascript @delayed
Feature: Work done in background
  In order to understand the status of the application
  An admin user
  Should be able to see when background workers are done

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And "job_batch_size" of source "Citeulike" is 200
    And "workers" of source "Citeulike" is 1
    And that we have 20 queued articles for "Citeulike"

    Scenario: Don't see stale articles
      When I go to the "Sources" admin page
      And I wait until all jobs for "Citeulike" have been processed
      Then I should not see stale articles for "Citeulike"

    Scenario: Don't see queued articles
      When I go to the "Sources" admin page
      And I wait until all jobs for "Citeulike" have been processed
      Then I should not see queued articles for "Citeulike"

    Scenario: Don't see jobs
      When I go to the "Sources" admin page
      And I wait until all jobs for "Citeulike" have been processed
      Then I should not see working jobs for "Citeulike"
      And I should not see pending jobs for "Citeulike"

    Scenario: Don't see jobs with not enough workers
      Given "job_batch_size" of source "Citeulike" is 10
      And "workers" of source "Citeulike" is 1
      When I go to the "Sources" admin page
      Then I should not see working jobs for "Citeulike"
      And I should not see pending jobs for "Citeulike"