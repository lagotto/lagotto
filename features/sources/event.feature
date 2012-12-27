Feature: Events
  In order see that we collect metrics correctly
  An admin user
  Should see the number and sum of events by source

  Background:
    Given I am logged in
    And the source "CiteULike" exists
    And that we have 10 articles
    
    @javascript
    Scenario: Responses from last 24 hours
      When I go to the "Summary" tab of source "CiteULike"
      Then I should see the "Total Events" column