@javascript
Feature: Background queueing
  In order to understand the status of the application
  An admin user
  Should be able to see the background queueing

  Background:
    Given I am logged in as "admin"
    And the source "Citeulike" exists with 1 worker and a job batch size of 200
    And we have 20 stale articles
    And we have 5 refreshed articles

    Scenario: See stale articles
      When I go to the "Sources" admin page
      Then I should see 20 stale articles for "CiteULike"

    Scenario: Queue all articles
      Given we have queued all articles
      When I go to the "Sources" admin page
      Then I should see 25 queued articles for "CiteULike"
      And I should see 0 stale articles for "CiteULike"
      And I should see 1 pending job for "CiteULike"

    Scenario: Queue all stale articles
      Given we have queued all stale articles
      When I go to the "Sources" admin page
      Then I should see 20 queued articles
      And I should see 0 stale articles for "CiteULike"
      And I should see 1 pending job for "CiteULike"

    Scenario: Queue all stale articles with job batch size
      And the source "Citeulike" exists with 1 worker and a job batch size of 10
      Given we have queued all articles
      When I go to the "Sources" admin page
      Then I should see 25 queued articles for "CiteULike"
      And I should see 0 stale articles for "CiteULike"
      And I should see 3 pending jobs for "CiteULike"

    Scenario: Queue one stale article
      Given we have queued one stale article
      When I go to the "Sources" admin page
      Then I should see 1 queued articles for "CiteULike"
      And I should see 19 stale articles for "CiteULike"
      And I should see 1 pending job for "CiteULike"