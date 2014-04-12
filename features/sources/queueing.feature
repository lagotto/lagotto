@javascript @delayed
Feature: Background queueing
  In order to understand the status of the application
  An admin user
  Should be able to see the background queueing

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists
    And "job_batch_size" of source "Citeulike" is 200
    And "workers" of source "Citeulike" is 1
    And we have 20 stale articles for "Citeulike"
    And we have 5 refreshed articles for "Citeulike"

    Scenario: See stale articles
      When I go to the "Sources" admin page
      Then I should see 20 stale articles for "Citeulike"

    Scenario Outline: Queue all articles if the source is active
      Given the status of source "Citeulike" is "<Status>"
      And we have queued all articles for "Citeulike"
      When I go to the "Sources" admin page
      Then I should see 25 queued articles for "Citeulike"
      And I should not see stale articles for "Citeulike"
      And I should see 1 pending job for "Citeulike"

      Examples:
      | Status      |
      | disabled    |
      | working     |
      | waiting     |

    Scenario: Don't queue articles if the source is inactive
      Given the status of source "Citeulike" is "inactive"
      And we have queued all articles for "Citeulike"
      When I go to the "Sources" admin page
      Then I should not see queued articles for "Citeulike"
      And I should not see stale articles for "Citeulike"
      And I should not see pending jobs for "Citeulike"

    Scenario: Queue all stale articles
      Given we have queued all stale articles for "Citeulike"
      When I go to the "Sources" admin page
      Then I should see 20 queued articles for "Citeulike"
      And I should not see stale articles for "Citeulike"
      And I should see 1 pending job for "Citeulike"

    Scenario: Queue all stale articles with job batch size
      Given "job_batch_size" of source "Citeulike" is 10
      And we have queued all articles for "Citeulike"
      When I go to the "Sources" admin page
      Then I should see 25 queued articles for "Citeulike"
      And I should not see stale articles for "Citeulike"
      And I should see 3 pending jobs for "Citeulike"

    Scenario: Queue one article
      Given we have queued one article for "Citeulike"
      When I go to the "Sources" admin page
      Then I should see 1 queued articles for "Citeulike"
      And I should see 19 stale articles for "Citeulike"
      And I should see 1 pending job for "Citeulike"